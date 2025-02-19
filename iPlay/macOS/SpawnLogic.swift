//
//  SpawnLogic.swift
//  iPlay
//
//  Created by Jack Seal on 2/6/25.
//

import Foundation

struct SpawnData {
    let spawnPoints: [(SpawnPoint, Bool)]
}

struct SpawnPoint {
    let x : CGFloat
    let y : CGFloat
}

enum InfectionError : Error {
    case InvalidPlayerCount
}

func generatePlayersSpawnPoint(playerCount: Int, mapWidth : CGFloat, mapHeight : CGFloat) throws -> SpawnData {
    guard playerCount >= 3, playerCount <= 8 else {
        throw InfectionError.InvalidPlayerCount
    }
    
    let xMargin = mapWidth * 0.05
    let yMargin = mapHeight * 0.05
    let cornerMargin = mapWidth * 0.1
    let xMidPoint = mapWidth / 2
    let yMidPoint = mapHeight / 2
    
    var spawnData: [(SpawnPoint, Bool)] = []
    
    let infectedIndex = Int.random(in: 0...(playerCount - 1))
    
    for i in 0..<(playerCount - 1) {
        let infected = (i == infectedIndex)
        var spawnPoint: SpawnPoint
        
        switch i {
        case 0: spawnPoint = SpawnPoint(x: CGFloat.random(in: cornerMargin...(xMidPoint - xMargin)), y: mapHeight - yMargin)
            
        case 1: spawnPoint = SpawnPoint(x: CGFloat.random(in: (xMidPoint + xMargin)...(mapWidth - cornerMargin)), y: yMargin)
            
        case 2: spawnPoint = SpawnPoint(x: mapWidth - xMargin, y: CGFloat.random(in: (yMidPoint + yMargin)...(mapHeight - yMargin)))
            
        case 3: spawnPoint = SpawnPoint(x: xMargin, y: CGFloat.random(in: cornerMargin...(yMidPoint - yMargin)))
            
        case 4: spawnPoint = SpawnPoint(x: CGFloat.random(in: (xMidPoint + xMargin)...(mapWidth - cornerMargin)), y: mapHeight - yMargin)
            
        case 5: spawnPoint = SpawnPoint(x: CGFloat.random(in: cornerMargin...(xMidPoint - xMargin)), y: yMargin)
            
        case 6: spawnPoint = SpawnPoint(x: mapWidth - xMargin, y: CGFloat.random(in: cornerMargin...(yMidPoint - yMargin)))
            
        default: spawnPoint = SpawnPoint(x: xMargin, y: CGFloat.random(in: (yMidPoint + yMargin)...(mapHeight - yMargin)))
        }
        
        spawnData.append((spawnPoint, infected))
    }
    
    return SpawnData(spawnPoints: spawnData)
}
