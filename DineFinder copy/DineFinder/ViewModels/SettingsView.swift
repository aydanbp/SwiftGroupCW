//
//  SettingsView.swift
//  CourseworkProofOConcept
//
//  Created by Aydan Buncombe-Paul on 05/04/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var DarkMode: Themes
    @EnvironmentObject var UserLoc : UserProperties
    @State var ApTog: Bool = false
    var body: some View {
        VStack {
            
            Image(systemName: "person.circle.fill")
                .imageScale(.large)
            
            Text("Settings View")
                .font(.headline)
            
            List{
                Section{
                    HStack{ //Controlls dark mode
                        Image(systemName: DarkMode.isDarkModeEnabled
                              ? "moon.fill" //true
                              : "sun.max.fill") //false
                        .imageScale(.large)
                        .animation(.smooth, value: DarkMode.isDarkModeEnabled)
                        .transition(.move(edge: .trailing))
                        
                        Toggle("Dark Mode",
                               isOn: $DarkMode.isDarkModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    HStack{ //Allows app to ask for user permissions
                        Image(systemName: "mappin.circle.fill")
                        Toggle("User location",
                               isOn: $UserLoc.permissionGranted)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                    }
                    HStack{ //Logout button
                        Image(systemName: "power.circle.fill")
                        Button("Logout", action: {
                            UserLoc.userIsLoggedIn = false
                        })
                    }
                    .foregroundStyle(.red)
                    
                }
                
                
                
                
                
                
                
            } //controlled by environmental object
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
}
