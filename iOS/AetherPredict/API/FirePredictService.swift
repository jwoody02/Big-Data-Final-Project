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
    
    public static let shared = FirePredictService()
    private var interpreter: Interpreter?

    private init() { }

    public func loadModel() {
        os_log(.debug, "Initializing FirePredictService")
        
        let modelFileName = "firepredict"
        guard let modelPath = Bundle.main.path(forResource: modelFileName, ofType: "tflite") else {
            os_log(.fault, "Failed to load the model file with name %@", modelFileName)
            return
        }
        os_log(.debug, "Loading model from \(modelPath)")
        do {
            self.interpreter = try Interpreter(modelPath: modelPath)
            try self.interpreter?.allocateTensors()
            os_log(.debug, "Successfully loaded firepredict.tflite into memory")
        } catch {
            os_log(.fault, "Error occurred while creating TensorFlow Lite Interpreter: %@", error.localizedDescription)
        }
    }

    func runModel(month: Float, temperature: Float, humidity: Float, windSpeed: Float, rain: Float, completion: @escaping (Double?) -> Void) {
        os_log(.debug, "Initiating model run..")
        guard let interpreter = self.interpreter else {
            os_log(.fault, "Interpreter is not initialized.")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        let input: [Float] = [month, temperature, humidity, windSpeed, rain]
        let inputData = Data(buffer: UnsafeBufferPointer(start: input, count: input.count))
        do {
            os_log(.debug, "Copying input data into interpreter")
            try interpreter.copy(inputData, toInputAt: 0)
            
            os_log(.debug, "Waiting for invokation result")
            try interpreter.invoke()

            guard let outputTensor = try? interpreter.output(at: 0) else {
                os_log(.fault, "Failed to get output tensor.")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let results = outputTensor.data.toArray(type: Double.self)
            os_log(.debug, "Successfully got output tensor: \(results.compactMap { String($0) })")
            DispatchQueue.main.async {
                completion(results.first)
            }
        } catch {
            os_log(.fault, "Failed to run model inference: %@", error.localizedDescription)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }


}

extension Data {
    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = [T](repeating: 0, count: self.count / MemoryLayout<T>.size)
        _ = array.withUnsafeMutableBytes { self.copyBytes(to: $0) }
        return array
    }
}
