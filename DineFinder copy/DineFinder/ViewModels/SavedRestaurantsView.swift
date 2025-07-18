//
//  Saved.swift
//  CourseworkProofOConcept
//
//  Created by Aydan Buncombe-Paul on 05/04/2025.
//

import SwiftUI
import SwiftData
import MapKit

struct SavedRestaurantsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var saved: [SavedModel]
    @EnvironmentObject var DarkMode: Themes
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saved")
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)

            if saved.isEmpty {
                EmptyView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(saved) { item in
                            HStack(alignment: .top, spacing: 12) {
                                ForeView(name: item.name, roadName: item.roadName)
                                Spacer()
                                
                                ButtonView(item: item)
                            }
                            .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .background(DarkMode.isDarkModeEnabled ? Color.black : Color.white)
        .colorScheme(DarkMode.isDarkModeEnabled ? .dark : .light)

    }
}
struct ForeView : View {
     var name : String
     var roadName : String
    var body: some View {
        
            // Icon
            Image(systemName: "fork.knife")
                .foregroundColor(.blue)
                .font(.title3)
                .padding(.top, 4)

            // Restaurant Info
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(roadName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            




        }

    }
}
struct EmptyView : View {
    var body: some View {
        Spacer()
        Text("No saved restaurants yet")
            .foregroundColor(.gray)
            .italic()
            .frame(maxWidth: .infinity)
        Spacer()
        
    }
}
struct ButtonView : View {
    @Environment(\.modelContext) private var modelContext
    var item : SavedModel
    @State var editNote : Bool = false
    @State var showMap : Bool = false
    var body: some View {
        HStack{
            // Optional: Map button (can expand later)
            Button(action: {
                showMap = true
            }) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.blue)
                    .imageScale(.large)
            }
            //Will take/Edit notes
            Button(action: {
                editNote = true
            }){
                Image(systemName: "square.and.pencil")
            }
            .foregroundColor(.blue)
            .imageScale(.large)
            
            // Delete Button
            Button(action: {
                modelContext.delete(item)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .imageScale(.large)
            }
        }
        .sheet(isPresented: $editNote) {
            EditNoteView(model: item)
            
        }
        .sheet(isPresented: $showMap) {
            SpecificView(model: item)
        }
    }
}
struct EditNoteView : View {
    @Environment(\.modelContext) var modelContext
    @State var model : SavedModel
    var body: some View {
        VStack{
                            Text("Notes for \(model.name)")
                    .font(.headline)
            
            TextEditor(text: $model.note)
                .multilineTextAlignment(.leading)
                .padding(8)
                .frame(maxWidth: 360, maxHeight: 600)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .clipped()
                
        }
        .padding(10)

            
    }
        
}
struct SpecificView : View {
    @State var model : SavedModel

    var body: some View {
        VStack{
            @State var region = CLLocationCoordinate2D(latitude: model.locationLat, longitude: model.locationLong)
            Text(model.name)
                .font(.headline)
            Text(model.roadName)
            Map()
            {
                Annotation("", coordinate: region){
                    Image(systemName: "fork.knife.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.red)
                        .font(.title2)
                        .background(Color.white.clipShape(Circle()))
                        .shadow(radius: 3)
                        
                }
            }
                .frame(width: 380, height: 200)
                .cornerRadius(10)
                .padding(10)
                .onTapGesture {
                    if let url = URL(string: "maps://?saddr=&daddr=\(model.locationLat),\(model.locationLong)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }

                                              
                }
        }
        .padding(10)

    }
}

#Preview {
    MainTabView()
        .environmentObject(Themes())
        .environmentObject(UserProperties()) 
}

