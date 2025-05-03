//
//  RestaurantModel.swift
//  CourseworkProofOConcept
//
//  Created by Ana 😋 on 14/04/2025.
//
import Foundation
import SwiftData

@Model
class RestaurantModel {
    var name: String
    var location: String
    var streetName: String
    var cuisine: String
    var visited: Bool

    init(name: String, location: String, streetName: String, cuisine: String, visited: Bool = false) {
        self.name = name
        self.location = location
        self.cuisine = cuisine
        self.visited = visited
        self.streetName = streetName
    }
}
