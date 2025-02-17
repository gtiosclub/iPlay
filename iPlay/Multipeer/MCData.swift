//
//  MCData.swift
//  iPlay
//
//  Created by Степан Кравцов on 2/13/25.
//

import Foundation

struct MCData: Codable {
    var id: String
    var data: Data?
    
    mutating func encodeData(id: String, data: Any) throws {
        switch id {
        case "infectedVector":
            let encodedData = try? JSONEncoder().encode(data as? Vector)
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
        case "infectedVector":
            let decodedData = try JSONDecoder().decode(Vector.self, from: data)
            guard decodedData is T else {
                throw MCDataError.invalidData(message: "The ID provided does not correspond to the provided data type")
            }
            return decodedData as! T
            
        default:
            throw MCDataError.invalidID(message: "\(id) is not supported for MCData")
        }
    }
    enum MCDataError: Error {
        case invalidID(message: String)
        case invalidData(message: String)
    }
}
