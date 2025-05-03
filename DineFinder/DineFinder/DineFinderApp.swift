//
//  DineFinderApp.swift
//  DineFinder
//
//  Created by Aydan Buncombe-Paul on 23/04/2025.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct CourseworkProofOConceptApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        let colours = Themes()
        let UDetails = UserProperties()
         
        WindowGroup {
            AuthView()
                .environmentObject(colours)
                .environmentObject(UDetails)
        }
        .modelContainer(for: SavedModel.self)
        
    }
}
class Themes : ObservableObject {
    @Published var isDarkModeEnabled : Bool = false
    enum Colors  {
        case red
        case green
        case blue
    }

}
class UserProperties : ObservableObject {
    @Published var permissionGranted : Bool = false
    @Published var userIsLoggedIn = false
}
