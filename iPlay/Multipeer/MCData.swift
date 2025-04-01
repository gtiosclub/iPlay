//
//  MCData.swift
//  iPlay
//
//  Created by Степан Кравцов on 2/13/25.
//

import Foundation
import AVFoundation
#if os(iOS)
import UIKit
#endif

struct MCData: Codable {
    var id: String
    var data: Data?
    
    mutating func encodeData(id: String, data: Any) throws {
        switch id {
        case "gameStateManagement":
            let encodedData = try? JSONEncoder().encode(data as? GameState)
            guard let encodedData = encodedData else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            self.data = encodedData
        case "infectedVector":
            let encodedData = try? JSONEncoder().encode(data as? Vector)
            guard let encodedData = encodedData else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            self.data = encodedData
        case "spectrumHintFromPrompter":
            let encodedData = try? JSONEncoder().encode(data as? MCDataString)
            guard let encodedData = encodedData else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            self.data = encodedData
        case "spectrumPrompt":
            let encodedData = try? JSONEncoder().encode(data as? SpectrumPrompt)
            guard let encodedData = encodedData else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            self.data = encodedData
        case "spectrumGameState":
            let encodedData = try? JSONEncoder().encode(data as? SpectrumGameState)
            guard let encodedData = encodedData else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            self.data = encodedData
        case "spectrumGuess":
            let encodedData = try? JSONEncoder().encode(data as? MCDataFloat)
            guard let encodedData = encodedData else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            self.data = encodedData
        case "infectedState":
            let encodedData = try? JSONEncoder().encode(data as? MCInfectedState)
            guard let encodedData = encodedData else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            self.data = encodedData
        default:
            throw MCDataError.invalidID(message: "\(id) is not supported for MCData")
        }
    }
    
    mutating func decodeData<T: Decodable>(id: String, as type: T.Type) throws -> T {
        guard let data else {
            throw MCDataError.invalidData(message: "Cannot decode, there is no data")
        }
        switch id {
        case "gameStateManagement":
            let decodedData = try JSONDecoder().decode(GameState.self, from: data)
            guard decodedData is T else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            return decodedData as! T
        case "infectedVector":
            let decodedData = try JSONDecoder().decode(Vector.self, from: data)
            guard decodedData is T else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            return decodedData as! T
        case "spectrumHintFromPrompter":
            let prompt = try JSONDecoder().decode(MCDataString.self, from: data)
            guard prompt is T else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            return prompt as! T
        case "spectrumPrompt":
            let prompt = try JSONDecoder().decode(SpectrumPrompt.self, from: data)
            guard prompt is T else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            return prompt as! T
        case "infectedState":
            let prompt = try JSONDecoder().decode(MCInfectedState.self, from: data)
            guard prompt is T else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            return prompt as! T
        case "spectrumGameState":
            let gameState = try JSONDecoder().decode(SpectrumGameState.self, from: data)
            guard gameState is T else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            return gameState as! T
        case "spectrumGuess":
            let guess = try JSONDecoder().decode(MCDataFloat.self, from: data)
            guard guess is T else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            return guess as! T
        default:
            throw MCDataError.invalidID(message: "\(id) is not supported for MCData")
        }
    }
    enum MCDataError: Error {
        case invalidID(message: String)
        case invalidData(message: String)
    }
    
#if os(iOS)
    mutating func convertImageToData(ciImage: CIImage) {
        let context = CIContext()
            
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                print("Couldn't convert image")
                return
            }
            
            let uiImage = UIImage(cgImage: cgImage)
            data = uiImage.jpegData(compressionQuality: 0.8) // Convert to JPEG
    }
#endif
}

