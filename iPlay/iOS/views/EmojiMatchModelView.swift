//
//  EmojiMatchModel.swift
//  iPlay
//
//  Created by Степан Кравцов on 4/1/25.
//

import SwiftUI
import CoreML
#if os(iOS)
import UIKit


struct EmojiMatchModelView: View {
    @State var resultText: String?
    var imageName: String = "angry2.jpg"
    var body: some View {
        Button(action: {makeModelPrediction(imageName: imageName)}) {
            Text("Predict Emotion")
        }
        Text(resultText ?? "No result")
        
    }
    
    
    func makeModelPrediction(imageName: String) {
        let emotionClasses = [
                0: "Anger",
                1: "Contempt",
                2: "Disgust",
                3: "Fear",
                4: "Happy",
                5: "Neutral",
                6: "Sad",
                7: "Surprised"
            ]
        let model1 = try! Yolo10L_Emotion_Detection()
        do {
            guard let buffer = createBuffer(imageName: imageName) else {
                        print("Failed to create buffer")
                        return
                    }
            
            // Run the model prediction
            let prediction = try model1.prediction(image: buffer)
            
            let modelOutput = prediction.var_2006
            let numDetections = modelOutput.shape[1].intValue
                    
                    // Dictionary to group detections by location
                    var detectionGroups: [String: [[Float]]] = [:]
                    
                    // Extract all detections
                    for i in 0..<numDetections {
                        var detection: [Float] = []
                        let valuesPerDetection = modelOutput.shape[2].intValue
                        
                        for j in 0..<valuesPerDetection {
                            let key = [0, i, j] as [NSNumber]
                            detection.append(modelOutput[key].floatValue)
                        }
                        print(detection)
                        
                        // Only process detections with positive probability
                        if detection[4] > 0.01 {
                            // Create a location key from the first 4 values
                            let locationKey = "\(detection[0]),\(detection[1]),\(detection[2]),\(detection[3])"
                            
                            // Add to appropriate group
                            if detectionGroups[locationKey] == nil {
                                detectionGroups[locationKey] = []
                            }
                            detectionGroups[locationKey]?.append(detection)
                            print(detection)
                        }
                    }
                    
                    // Process each group to find max probability
                    var finalDetections: [[Float]] = []
                    
                    for (_, detections) in detectionGroups {
                        // Find detection with maximum probability in this group
                        if let maxDetection = detections.max(by: { $0[4] < $1[4] }) {
                            finalDetections.append(maxDetection)
                            
                            let classIndex = Int(maxDetection[5])
                            let probability = maxDetection[4]
                            
                            let emotionName = emotionClasses[classIndex] ?? "Unknown"
                                
                        }
                    }
                    
                  
                    
                    // If you need the overall best detection
                    if let bestDetection = finalDetections.max(by: { $0[4] < $1[4] }) {
                        let bestClass = Int(bestDetection[5])
                        let bestProb = bestDetection[4]
                        let emotionName = emotionClasses[bestClass] ?? "Unknown"
                        print("Overall best: Class \(emotionName) with probability \(bestProb)")
                        let text = "\(emotionName): \(Int(bestProb * 100))%"
                        self.resultText = text
                    }
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    func createBuffer(imageName: String) -> CVPixelBuffer? {
        guard let uiImage = UIImage(named: imageName) else { return nil }
        guard let cgImage = uiImage.cgImage else { return nil }
        
        let width = 640
        let height = 640
        
        // Get raw image data
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        
        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)
        
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        // Draw the image to extract pixel data
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary,
            &pixelBuffer
        )
        
        guard let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, .init(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(buffer, .init(rawValue: 0)) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let bufferBytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
 
        let ptr = baseAddress.assumingMemoryBound(to: UInt8.self)
        
        for y in 0..<height {
            for x in 0..<width {
                let sourceOffset = (y * bytesPerRow) + (x * 4)
                let destOffset = (y * bufferBytesPerRow) + (x * 4)
                
                // Map from RGBA to BGRA
                // Python order is BGR (no alpha)
                ptr[destOffset + 0] = 255                   // Alpha (full opacity)
                ptr[destOffset + 1] = rawData[sourceOffset + 2] // Blue
                ptr[destOffset + 2] = rawData[sourceOffset + 1] // Green
                ptr[destOffset + 3] = rawData[sourceOffset + 0] // Red
            }
        }
        
        
        
        return buffer
    }
}


#Preview {
    EmojiMatchModelView()
}
#endif
