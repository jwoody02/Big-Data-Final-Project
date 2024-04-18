// python to swift translation using https://www.codeconvert.ai/python-to-swift-converter
// needs to be debugged/tested
import Foundation
import TensorFlow

// read input data that had been stored in a csv file 
// (this is just an illustration; the IOS forest fire prediction app will likely pass the input data in a different manner)
let df = try! CSVReader(url: URL(fileURLWithPath: "input_from_IOS_app.csv")).read()
let monthnum_season_mapping: [Int: Int] = [1: 0, 2: 0, 3: 1, 4: 1, 5: 1, 6: 2, 7: 2, 8: 2, 9: 3, 10: 3, 11: 3, 12: 0]
let X = df.map { row in
    Array(row[0..<4].map { Double($0) })
}

// test read the saved TF Lite model
let tflite_model = try! Data(contentsOf: URL(fileURLWithPath: "NN_model.tflite"))

// Load the TFLite model and allocate tensors
let interpreter = try! TFLiteInterpreter(modelContent: tflite_model)
try! interpreter.allocateTensors()

// Get input and output tensors
let input_details = interpreter.getInputTensor(at: 0)
let output_details = interpreter.getOutputTensor(at: 0)

// run the TFLite model to predict the fire risk (0: No risk; 1: Fire risk)
let input_data = Tensor<Float>(X)
try! interpreter.invoke(with: [input_data])
let p = interpreter.output(at: 0)
let y = p.where(p .> 0.5, 1, 0)
print(y)
