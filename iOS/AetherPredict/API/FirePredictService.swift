//
//  FirePredictService.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/14/24.
//

import Foundation
import os.log
import TensorFlowLite

class FirePredictService {
    private var interpreter: Interpreter?

    init() {
        loadModel()
    }

    private func loadModel() {
        // Load model into memory in a seperate thread
        DispatchQueue.global(qos: .userInitiated).async {
            let modelFileName = "firepredict"
            guard let modelPath = Bundle.main.path(forResource: modelFileName, ofType: "tflite") else {
                os_log(.fault, "Failed to load the model file with name \(modelFileName).")
                return
            }

            do {
                self.interpreter = try Interpreter(modelPath: modelPath)
                try self.interpreter?.allocateTensors()
            } catch {
                os_log(.fault, "Error occurred while creating TensorFlow Lite Interpreter: \(error)")
            }
        }
    }

    func runModel(month: Float, temperature: Float, humidity: Float, windSpeed: Float, rain: Float, completion: @escaping (Double?) -> Void) {
        // Run inference on model in seperate thread (prevent UI from freezing)
        DispatchQueue.global(qos: .userInitiated).async {
            guard let interpreter = self.interpreter else {
                os_log(.fault, "Interpreter is not initialized.")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let input: [Float] = [month, temperature, humidity, windSpeed, rain]
            do {
                let inputData = Data(copyingBufferOf: input)
                try interpreter.copy(inputData, toInputAt: 0)
                try interpreter.invoke()

                if let outputTensor = try interpreter.output(at: 0),
                   let result = outputTensor.data.toArray(type: Double.self).first {
                    DispatchQueue.main.async {
                        // pass back result on main thread
                        completion(result)
                    }
                } else {
                    os_log(.fault, "Failed to get result from output tensor.")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                os_log(.fault, "Failed to run model inference: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

// Helper extension to convert Data to Array
extension Data {
    func toArray<T>(type: T.Type) -> [T] where T: FixedWidthInteger {
        var array = [T](repeating: 0, count: self.count / MemoryLayout<T>.size)
        self.copyBytes(to: &array, count: self.count)
        return array
    }
}
