//
//  YelpModel.swift
//  CourseworkProofOConcept
//
//  Created by Ana 😋 on 15/04/2025.
//
import Foundation
import MapKit

// Full response object
struct YelpResponse: Codable {
    let businesses: [Business]
    
}

// Each business (restaurant)
struct Business: Codable, Identifiable {
    let id: String
    let name: String
    let rating: Double
    let location: Location
    let url: String
    let image_url: String
    let distance: Double
    let coordinates: Coordinates
    
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct Location: Codable {
    let address1: String?
    let city: String
}


