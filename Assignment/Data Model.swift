//
//  Data Model.swift
//  Assignment
//
//  Created by Sambhav Singh on 11/01/25.
//

import Foundation

struct DietResponse: Codable {
    let status: String
    let message: String
    let data: DietData
}

struct DietData: Codable {
    let diets: Diets
}

struct Diets: Codable {
    let dietStreak: [String]
    let allDiets: [Diet]
}

struct Diet: Codable, Identifiable {
    var id: String { daytime }
    let daytime: String
    let timings: String
    let progressStatus: ProgressStatus
    let recipes: [Recipe]
}


struct ProgressStatus: Codable {
    let total: Int
    let completed: Int
}

struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String
    let timeSlot: String
    let duration: Int
    let image: String
    let isFavorite: Int
    let isCompleted: Int
}
