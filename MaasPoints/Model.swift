//
//  Model.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 21.05.2022.
//

import Foundation

// MARK: - Welcome10
struct Place: Codable {
    let features: [Feature]
}

// MARK: - Feature
struct Feature: Codable {
    let type: String
    let properties: Properties
    let geometry: Geometry
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}

// MARK: - Properties
struct Properties: Codable {
    let location, discipline, title: String
}

