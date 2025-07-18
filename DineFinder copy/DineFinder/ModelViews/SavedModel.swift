//
//  SavenModel.swift
//  CourseworkProofOConcept
//
//  Created by Aydan Buncombe-Paul on 19/04/2025.
//


import Foundation
import MapKit
import SwiftData

@Model class SavedModel: Identifiable {
    var selected: Bool = false
    var name: String
    var locationLong: Double
    var locationLat: Double
    var roadName: String
    var note : String = nil ?? ""
    
//    var rating: Double
//    var url: String
    

    init(name: String, roadName: String, locationLong: Double, locationLat: Double) {
       self.name = name
        
        self.roadName = roadName
        self.locationLat = locationLat
        self.locationLong = locationLong
    }
 }
