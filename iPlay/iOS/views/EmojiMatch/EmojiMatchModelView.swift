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
//        Button(action: {makeModelPrediction(imageName: imageName)}) {
//            Text("Predict Emotion")
//        }
        Text(resultText ?? "No result")
        
    }
    
    func makeModelPrediction(image: CGImage?, targetEmotion: String) -> Double {
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
        
        let model = try! Yolo10L_Emotion_Detection()
        
        do {
            guard let buffer = createBuffer(image: image) else {
                print("Failed to create buffer")
                return 0.0
            }
            
            let prediction = try model.prediction(image: buffer)
            let modelOutput = prediction.var_2006
            let numDetections = modelOutput.shape[1].intValue
            
            var detectionGroups: [String: [[Float]]] = [:]
            
            for i in 0..<numDetections {
                var detection: [Float] = []
                let valuesPerDetection = modelOutput.shape[2].intValue
                
                for j in 0..<valuesPerDetection {
                    let key = [0, i, j] as [NSNumber]
                    detection.append(modelOutput[key].floatValue)
                }
                
                if detection[4] > 0.01 {
                    let locationKey = "\(detection[0]),\(detection[1]),\(detection[2]),\(detection[3])"
                    
                    if detectionGroups[locationKey] == nil {
                        detectionGroups[locationKey] = []
                    }
                    detectionGroups[locationKey]?.append(detection)
                }
            }
            
            var finalDetections: [[Float]] = []
            
            for (_, detections) in detectionGroups {
                if let maxDetection = detections.max(by: { $0[4] < $1[4] }) {
                    finalDetections.append(maxDetection)
                }
            }
            
            // Find best match for the given emotion
            if let targetClass = emotionClasses.first(where: { $0.value.lowercased() == targetEmotion.lowercased() })?.key {
                let matchingDetections = finalDetections.filter { Int($0[5]) == targetClass }
                if let bestMatch = matchingDetections.max(by: { $0[4] < $1[4] }) {
                    let confidence = bestMatch[4]
                    return Double(confidence * 100)
                } else {
                    return 0.0
                }
            } else {
                return 0.0
            }
            
        } catch {
            print("Error: \(error)")
            return 0.0
        }
    }

    
    
    func createBuffer(image: CGImage?) -> CVPixelBuffer? {
        guard let cgImage = image else { return nil }

        let targetWidth = 640
        let targetHeight = 640

        let imageWidth = cgImage.width
        let imageHeight = cgImage.height

        let aspectWidth = CGFloat(targetWidth) / CGFloat(imageWidth)
        let aspectHeight = CGFloat(targetHeight) / CGFloat(imageHeight)
        let aspectRatio = min(aspectWidth, aspectHeight)

        let scaledWidth = CGFloat(imageWidth) * aspectRatio
        let scaledHeight = CGFloat(imageHeight) * aspectRatio
        let xOffset = (CGFloat(targetWidth) - scaledWidth) / 2
        let yOffset = (CGFloat(targetHeight) - scaledHeight) / 2

        var rawData = [UInt8](repeating: 0, count: targetHeight * targetWidth * 4)

        guard let context = CGContext(
            data: &rawData,
            width: targetWidth,
            height: targetHeight,
            bitsPerComponent: 8,
            bytesPerRow: targetWidth * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        // Fill background with black (or neutral gray) if needed
        context.setFillColor(CGColor(gray: 0.5, alpha: 1.0))  // optional
        context.fill(CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))

        // Draw scaled image centered in the canvas
        let drawRect = CGRect(x: xOffset, y: yOffset, width: scaledWidth, height: scaledHeight)
        context.draw(cgImage, in: drawRect)

        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            targetWidth,
            targetHeight,
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

        for y in 0..<targetHeight {
            for x in 0..<targetWidth {
                let sourceOffset = (y * targetWidth + x) * 4
                let destOffset = (y * bufferBytesPerRow) + (x * 4)

                // RGBA -> BGRA
                ptr[destOffset + 0] = rawData[sourceOffset + 2] // Blue
                ptr[destOffset + 1] = rawData[sourceOffset + 1] // Green
                ptr[destOffset + 2] = rawData[sourceOffset + 0] // Red
                ptr[destOffset + 3] = rawData[sourceOffset + 3] // Alpha
            }
        }

        return buffer
    }
}


#Preview {
    EmojiMatchModelView()
}
#endif
