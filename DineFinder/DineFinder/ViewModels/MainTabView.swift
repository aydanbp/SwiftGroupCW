//
//  TabView.swift
//  CourseworkProofOConcept
//
//  Created by Aydan Buncombe-Paul on 05/04/2025.
//

import SwiftUI


struct MainTabView: View {
    @EnvironmentObject var DarkMode: Themes
    var body: some View {
        TabView {
            DineFinderMainView().tabItem {
                Label("Home", systemImage: "house")
            }
            SavedRestaurantsView().tabItem {
                Label("Saved", systemImage: "bookmark")
            }
            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }
            
        }
        .shadow(color: .black, radius: 5)
        .background(DarkMode.isDarkModeEnabled
                    ?Color.black //true
                    :Color.white //false
        )
        .colorScheme(DarkMode.isDarkModeEnabled
                     ?.dark
                     :.light
        )
        
    }
}

#Preview {
    MainTabView()
        .environmentObject(Themes())
        .environmentObject(UserProperties()) 
}
