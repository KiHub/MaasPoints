//
//  Model.swift
//  MaasPoints
//
//  Created by  Mr.Ki on 21.05.2022.
//

import Foundation

struct Place: Codable {
    let features: [Feature]
}

struct Feature: Codable {
    let type: String
    let properties: Properties
    let geometry: Geometry
}

struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}

struct Properties: Codable {
    let location, discipline, title: String
}

