//
//  ContentView.swift
//  DineFinder
//
//  Created by Ana 😋 & Aydan Buncombe-Paul on 23/04/2025.
//

import SwiftUI
import MapKit
import SwiftData
import CoreLocation

struct DineFinderMainView: View {
    
    @StateObject var viewModel = AskLocation()
    @ObservedObject var mapViewModel = MapViewModel()
    @EnvironmentObject var DarkMode: Themes
    @EnvironmentObject var ULoc: UserProperties
    @State private var showDetails = false
    @State private var locationEmpty = false
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5072, longitude: -0.1276),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    @State private var mapLocation = ""
    @State private var query: String = ""
    @State private var showSearchResults: Bool = false
    @State var ManSearch : Bool = false
    
    
    var body: some View {
        GeometryReader { geo in
                VStack() {
                    /*
                     This error kept occuring "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
                     The view grew too big and Swift couldn't read it. Had to be split up
                     */
                    // MARK: Search Inputs
                    SearchBarHScroll(query: $query, ManSearch: $ManSearch, mapLocation: $mapLocation, showSearchResults: $showSearchResults, mapViewModel: mapViewModel, region: $region)
                    if ManSearch {
                        SearchBar(query: $query, mapLocation: $mapLocation, showSearchResults: $showSearchResults, mapViewModel: mapViewModel, region: $region)
                            .transition(.slide)
                            .animation(.smooth, value: ManSearch)
                    }
                    
                    
                    
                    // MARK: Map
                    ZStack(alignment: .bottom){
                        MapView(mapViewModel: mapViewModel, region: $region, showDetails: $showDetails)
                            .onAppear(perform: {
                                if ULoc.permissionGranted {
                                    viewModel.checkIfLocationIsEnabled()
                                }
                                
                            })
                        
                        
                        Spacer()
                        // MARK: Results List
                        
                        
                        if showSearchResults {
                            VStack{
                                
                                
                                Button("Dismiss"){
                                    showSearchResults = false
                                }
                                .frame(width: 100, height: 30)
                                .background(Color.gray)
                                .cornerRadius(8)
                                .foregroundStyle(.white)
                                
                                ScrollView{
                                    Resultsview(showSearchResults: $showSearchResults, mapViewModel: mapViewModel)
                                }
                                
                                .background(.ultraThinMaterial)
                                
                            }
                            .frame(height: 350)
                        
                    }
                    
                }
            }
        }
        
        .sheet(isPresented: $showDetails) {
            if let restaurant = mapViewModel.selectedRestaurant {
                ReviewView(restaurant: restaurant)
            }
        }
        
        .padding()
        .background(DarkMode.isDarkModeEnabled ? Color.black : Color.white)
        .colorScheme(DarkMode.isDarkModeEnabled ? .dark : .light)
    }
    
    
    
}
//Text based search bar. Now appears on tap
struct SearchBar: View {
    @Binding var query: String
    @Binding var mapLocation: String
    @Binding var showSearchResults : Bool
    @EnvironmentObject var ULoc: UserProperties
    @ObservedObject var mapViewModel : MapViewModel
    @Binding var region : MKCoordinateRegion
    var body: some View {
        HStack(spacing: 8) {
            
            Button("", systemImage: "magnifyingglass", action: PerformSearch)
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.gray)
            
            TextField("Search for food or places", text: $query)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                .onSubmit {PerformSearch()}
            
            TextField("Location", text: $mapLocation)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                .onSubmit {
                    PerformSearch()
                }
            
            
        }
        .padding(.horizontal)
    }
    func PerformSearch() {
        showSearchResults = true
        if ULoc.permissionGranted && mapLocation.isEmpty {
            mapViewModel.getCoordinates(query: query, coordinates: region.center)}
        //if no map location is given, the current region is sent
        else{
            mapViewModel.getCoordinates(query: query, locale: mapLocation)
        }
        
        Task {
            do {
                try await mapViewModel.setAnnotations(query: query)
            } catch {
                print("Error fetching annotations: \(error)")
            }
        }
        hideKeyboard()
        
    }
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SearchBarHScroll : View {
    @Binding var query: String
    @Binding var ManSearch : Bool
    @Binding var mapLocation: String
    @Binding var showSearchResults : Bool
    @EnvironmentObject var ULoc: UserProperties
    @ObservedObject var mapViewModel : MapViewModel
    @Binding var region : MKCoordinateRegion
    
    var foods = ["Fish", "Italian", "Burger", "Mexican", "Pizza", "Chinese", "French", "Indian", "Japanese", "Thai"]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(foods, id: \.self){ food in
                    Button("\(food)", systemImage: "fork.knife.circle.fill") {
                        query = food
                        PerformSearch()
                    }.imageScale(.large)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                        .symbolRenderingMode(.hierarchical)
                    
                    
                    
                }
                //Allow access to text search bar
                Toggle("Other", systemImage: ManSearch ? "chevron.down.circle.fill" : "chevron.right.circle"
                       , isOn: $ManSearch)
                .toggleStyle(.button)
                .tint(Color.gray)
                .imageScale(.large)
                .fontWeight(.bold)
                .foregroundStyle(.gray)
                .symbolRenderingMode(.hierarchical)
                .background()
                .animation(.linear, value: ManSearch)
            }
            
            
        }
    }
    func PerformSearch() {
        showSearchResults = true
        mapViewModel.getCoordinates(query: query, coordinates: region.center)
        // unable to enter location w/ horizontal scroll. Always passes region
        Task {
            do {
                try await mapViewModel.setAnnotations(query: query)
            } catch {
                print("Error fetching annotations: \(error)")
            }
        }
        
    }
}

struct MapView : View{
    @ObservedObject var mapViewModel : MapViewModel
    
    @Binding var region : MKCoordinateRegion
    @Binding var showDetails: Bool
    @EnvironmentObject var ULoc: UserProperties
    @State var tracking : MapUserTrackingMode = .follow
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(
                coordinateRegion: $region,
                interactionModes: [.all],
                showsUserLocation: ULoc.permissionGranted,
                userTrackingMode: $tracking,
                annotationItems: mapViewModel.restaurants
            ) { restaurant in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: restaurant.coordinates.latitude,
                    longitude: restaurant.coordinates.longitude
                )) {
                    Button {
                        mapViewModel.selectedRestaurant = restaurant
                        showDetails = true
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "fork.knife.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                                .background(Color.white.clipShape(Circle()))
                                .shadow(radius: 3)
                            Text(restaurant.name)
                                .font(.caption)
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .frame(width: 100)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .task {
                //
                await Task.sleep(2_000_000_000) // Sleep for 2 seconds
                tracking = .follow
            }
                
            
            
            // MARK: Zoom Buttons
            VStack(spacing: 12) {
                Button(action: {
                    // Zoom in
                    region.span.latitudeDelta /= 2
                    region.span.longitudeDelta /= 2
                }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.title3)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
                
                Button(action: {
                    // Zoom out
                    region.span.latitudeDelta *= 2
                    region.span.longitudeDelta *= 2
                }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.title3)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 3)
                }
            }
            .padding()
        }
    }
}

struct Resultsview: View {
    @Binding var showSearchResults: Bool
    @Query var saved: [SavedModel]
    @ObservedObject var mapViewModel = MapViewModel()
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        
        VStack(spacing: 12) {
            ForEach(mapViewModel.restaurants) { restaurant in
                HStack(alignment: .top, spacing: 12) {
                    // Add/Saved Button
                    Button(action: {
                        if !isAlreadySaved(restaurant) {
                            let savedRestaurant = SavedModel(
                                name: restaurant.name,
                                roadName: restaurant.location.address1 ?? "",
                                locationLong: restaurant.coordinates.longitude, locationLat: restaurant.coordinates.latitude
                            )
                            modelContext.insert(savedRestaurant)
                        }
                    }) {
                        Text(isAlreadySaved(restaurant) ? "Saved" : "Add")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 6)
                                                    .padding(.horizontal, 12)
                                                    .background(isAlreadySaved(restaurant) ? Color.green : Color.blue)
                                                    .cornerRadius(8)
                                                    .shadow(
                                                        color: isAlreadySaved(restaurant) ? Color.green.opacity(0.4) : .clear,
                                                        radius: 5,
                                                        x: 0,
                                                        y: 2
                                                    )
                    }
                    .disabled(isAlreadySaved(restaurant))
                    
                    // Name & Address
                    VStack(alignment: .leading, spacing: 4) {
                        Text(restaurant.name)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if let address = restaurant.location.address1 {
                            Text(address)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    // Helper function must be *inside* the same struct
    func isAlreadySaved(_ restaurant: Business) -> Bool {
        saved.contains {
            $0.name == restaurant.name &&
            $0.roadName == (restaurant.location.address1 ?? "")
        }
    }
}




// MARK: - Review View
struct ReviewView: View {
    @Query var saved: [SavedModel]
    let restaurant: Business
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        Spacer()
        
        VStack(spacing: 16) {
            let partStar = restaurant.rating.truncatingRemainder(dividingBy: 1)
            var blankStar = partStar >= 0.5 ? 5.0 - restaurant.rating.rounded(.down)-1 : 5.0 - restaurant.rating.rounded(.down)
            AsyncImage(url: URL(string: restaurant.image_url)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(height: 200)
            .cornerRadius(12)
            
            Text(restaurant.name)
                .font(.title2).bold()
            
            Text("Rating: \(restaurant.rating, specifier: "%.1f") ⭐️")
                .font(.subheadline)
            
            HStack(spacing: 4) {
                // Show full stars based on rounded rating
                ForEach(0..<Int(restaurant.rating.rounded(.down)), id: \.self) { _ in
                    
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                //is business has over .5 stars they get a part star
                if partStar >= 0.5 {
                    
                    Image(systemName: "star.leadinghalf.filled")
                        .foregroundStyle(.yellow)
                    
                }
                //Remainder stars blank
                ForEach(0..<Int(blankStar), id: \.self) { _ in
                    
                    Image(systemName: "star")
                        .foregroundStyle(.yellow)
                }
            }
            
            
            if let address = restaurant.location.address1 {
                Text(address)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            Link("View on Yelp", destination: URL(string: restaurant.url)!)
                .padding(.top, 10)
            //Add button
            Button(action: {
                if !isAlreadySaved(restaurant) {
                    let savedRestaurant = SavedModel(
                        name: restaurant.name,
                        roadName: restaurant.location.address1 ?? "", locationLong: restaurant.coordinates.longitude, locationLat: restaurant.coordinates.latitude
                    )
                    modelContext.insert(savedRestaurant)
                }
            }) {
                Text(isAlreadySaved(restaurant) ? "Saved" : "Add")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .padding(.vertical, 6)
                                                .padding(.horizontal, 12)
                                                .background(isAlreadySaved(restaurant) ? Color.green : Color.blue)
                                                .cornerRadius(8)
                                                .shadow(
                                                    color: isAlreadySaved(restaurant) ? Color.green.opacity(0.4) : .clear,
                                                    radius: 5,
                                                    x: 0,
                                                    y: 2
                                                )
            }
            Spacer()
        }
        .padding()
    }
    func isAlreadySaved(_ restaurant: Business) -> Bool {
        saved.contains {
            $0.name == restaurant.name &&
            $0.roadName == (restaurant.location.address1 ?? "")
        }
    }
    
}

final class AskLocation: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    
    @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.457105, longitude: -80.508361), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    var binding: Binding<MKCoordinateRegion> {
        Binding {
            self.mapRegion
        } set: { newRegion in
            self.mapRegion = newRegion
        }
    }
    
    func checkIfLocationIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
        } else {
            print("Show an alert letting them know this is off")
        }
    }
    //Checks if location permission has been updated
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let previousAuthorizationStatus = manager.authorizationStatus
        manager.requestWhenInUseAuthorization()
        if manager.authorizationStatus != previousAuthorizationStatus {
            checkLocationAuthorization()
        }
    }
    
    private func checkLocationAuthorization() {
        guard let location = locationManager else {
            return
        }
        //If permission granted, map region is chaged to user's current location
        switch location.authorizationStatus {
        case .notDetermined:
            print("Location authorization is not determined.")
        case .restricted:
            print("Location is restricted.")
        case .denied:
            print("Location permission denied.")
        case .authorizedAlways, .authorizedWhenInUse:
            if let location = location.location {
                mapRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            }
            
        default:
            break
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(Themes())
        .environmentObject(UserProperties())
    
    .modelContainer(for: SavedModel.self)
    //Note: inject model & EOs for fuctional previews
    
}


