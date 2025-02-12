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
    var spawnData: [(SpawnPoint, Bool)] = []
    
    let infectedIndex = Int.random(in: 0...(playerCount - 1))
    
    for i in 0..<(playerCount - 1) {
        let infected = (i == infectedIndex)
        let spawnPoint: SpawnPoint
        
        if playerCount % 4 == 0 {
            spawnPoint = SpawnPoint(x: CGFloat.random(in: xMargin...(mapWidth - xMargin)), y: mapHeight - yMargin)
        } else if playerCount % 4 == 1 {
            spawnPoint = SpawnPoint(x: CGFloat.random(in: xMargin...(mapWidth - xMargin)), y: yMargin)
        } else if playerCount % 4 == 2 {
            spawnPoint = SpawnPoint(x: xMargin, y: CGFloat.random(in: yMargin...(mapHeight - yMargin)))
        } else {
            spawnPoint = SpawnPoint(x: mapWidth - xMargin, y: CGFloat.random(in: yMargin...(mapHeight - yMargin)))
        }
        
        spawnData.append((spawnPoint, infected))
    }
    
    return SpawnData(spawnPoints: spawnData)
}
