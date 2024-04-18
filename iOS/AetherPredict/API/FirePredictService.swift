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
    private var linearRegModelInterpreter: Interpreter?
    private var neuralNetModelInterpreter: Interpreter?


    private init() { }

    public func loadLinearRegModel() {
        let modelFileName = "lr_model"
        guard let modelPath = Bundle.main.path(forResource: modelFileName, ofType: "tflite") else {
            os_log(.fault, "Failed to load the model file with name %@", modelFileName)
            return
        }
        do {
            self.linearRegModelInterpreter = try Interpreter(modelPath: modelPath)
            try self.linearRegModelInterpreter?.allocateTensors()
            os_log(.debug, "Initialized linear reg. model..")
        } catch {
            os_log(.fault, "Error occurred while creating TensorFlow Lite Interpreter: %@", error.localizedDescription)
        }
    }
    
    public func loadNeuralNetModel() {
        let modelFileName = "NN_model"
        guard let modelPath = Bundle.main.path(forResource: modelFileName, ofType: "tflite") else {
            os_log(.fault, "Failed to load the model file with name %@", modelFileName)
            return
        }
        do {
            self.neuralNetModelInterpreter = try Interpreter(modelPath: modelPath)
            try self.neuralNetModelInterpreter?.allocateTensors()
            os_log(.debug, "Initialized neural network model..")
        } catch {
            os_log(.fault, "Error occurred while creating TensorFlow Lite Interpreter: %@", error.localizedDescription)
        }
    }

    func runLinearRegModel(
        month: Int,
        temperature: Float,
        humidity: Float,
        windSpeed: Float,
        rain: Bool,
        completion: @escaping (Float?) -> Void
    ) {
        os_log(.debug, "Initiating linear reg. model run..")
        guard let interpreter = self.linearRegModelInterpreter else {
            os_log(.fault, "Linear reg. interpreter is not initialized.")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        var input: [Float] = [temperature, humidity, windSpeed, rain ? 1.0 : 0.0]
        for i in 1...12 {
            input.append(i == Int(month) ? 1 : 0)
        }
        
        let inputData = Data(buffer: UnsafeBufferPointer(start: input, count: input.count))
        do {
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()

            guard let outputTensor = try? interpreter.output(at: 0) else {
                os_log(.fault, "Failed to get output tensor from lin reg.")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let resultFloat = outputTensor.data.withUnsafeBytes( { $0.load(as: Float.self )})
            let originalValue = exp(resultFloat) - 1
            
            os_log(.debug, "Linear regression prediction: \(originalValue*2.47) acres will burn")
            
            DispatchQueue.main.async {
                completion(originalValue*2.47)
            }
        } catch {
            os_log(.fault, "Failed to run model inference: %@", error.localizedDescription)
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    // input: month (int from 1-12), temperature (C int), Humidity (0-100), Wind speed (km/h),
    // Output: Boolean (0 no risk, 1 high risk)
    func runNeuralNetModel(
        month: Int,
        temperature: Float,
        humidity: Float,
        windSpeed: Float,
        completion: @escaping (Bool?) -> Void
    ) {
        os_log(.debug, "Initiating neural net model run..")
        guard let interpreter = self.neuralNetModelInterpreter else {
            os_log(.fault, "Neural net interpreter is not initialized.")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        let monthnum_season_mapping: [Int: Int] = [1: 0, 2: 0, 3: 1, 4: 1, 5: 1, 6: 2, 7: 2, 8: 2, 9: 3, 10: 3, 11: 3, 12: 0]
        let input: [Float] = [Float(monthnum_season_mapping[month] ?? 0), temperature, humidity, windSpeed]
        let inputData = Data(buffer: UnsafeBufferPointer(start: input, count: input.count))
        do {
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()

            guard let outputTensor = try? interpreter.output(at: 0) else {
                os_log(.fault, "Failed to get output tensor from neural net.")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let result = outputTensor.data.withUnsafeBytes( { $0.load(as: Bool.self )})
            
            os_log(.debug, "Neural net prediction for wildfire: \(result)")
            
            DispatchQueue.main.async {
                completion(result)
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
