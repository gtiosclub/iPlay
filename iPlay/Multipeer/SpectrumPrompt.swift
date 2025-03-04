//
//  SpectrumPrompt.swift
//  iPlay
//
//  Created by Danny Byrd on 3/1/25.
//

import Foundation

class SpectrumPrompt: Codable {
    let num: Int
    let prompt: String
    var isHinter = false

    init() {
        self.num = Int.random(in: 0...10)
        self.prompt = SpectrumPrompts.allCases.randomElement()!.rawValue
    }
}

enum SpectrumPrompts: String, CaseIterable {
    case FastFood = "Fast Food"
    case MoviePopularity = "Movie Popularity"
    case SpicinessOfFood = "Spiciness Of Food"
    case Expensiveness = "Expensiveness"
    case DangerousAnimals = "Dangerous Animals"
    case FameOfCelebrities = "Fame Of Celebrities"
    case StrengthOfSuperheroes = "Strength Of Superheroes"
    case CutenessOfAnimals = "Cuteness Of Animals"
    case LoudestNoises = "Loudest Noises"
    case WorstSmells = "Worst Smells"
    case MostFunActivities = "Most Fun Activities"
    case ScariestHorrorMovies = "Scariest Horror Movies"
    case MostUsefulInventions = "Most Useful Inventions"
    case DifficultSports = "Most Difficult Sports"
    case MostAnnoyingSounds = "Most Annoying Sounds"
    case SmartestAnimals = "Smartest Animals"
    case HardestSchoolSubjects = "Hardest School Subjects"
    case MostAddictiveSnacks = "Most Addictive Snacks"
    case CoolestJobs = "Coolest Jobs"
    case MostOverratedThings = "Most Overrated Things"
}

