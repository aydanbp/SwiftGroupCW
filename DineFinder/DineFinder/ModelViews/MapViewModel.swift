
import Foundation
import SwiftUI
import CoreLocation
import MapKit

class MapViewModel: ObservableObject {
    @Published var mapLocation: String = ""
    @Published var coordinates: CLLocationCoordinate2D?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()
    @Published var restaurants: [Business] = []
    @Published var selectedRestaurant: Business? = nil
    @Published var desired: String = ""
    
    @StateObject private var locationManager = LocationManager()
    
    func getCoordinates(query: String, locale: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locale) { placemarks, error in
            if let location = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    self.coordinates = location
                    self.region = MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )
                    print("Searching near lat: \(location.latitude), long: \(location.longitude) for \(query)")
                }
                
                YelpService().fetchRestaurants(
                    term: query,
                    latitude: location.latitude,
                    longitude: location.longitude
                ) { fetched in
                    DispatchQueue.main.async {
                        self.restaurants = fetched
                    }
                }
            } else {
                print("Location not available yet")
            }
        }
    }
    
    //Used when user location is avalible
    func getCoordinates(query: String, coordinates: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            self.coordinates = coordinates
            self.region = MKCoordinateRegion(
                center: coordinates,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            print("Searching near lat: \(coordinates.latitude), long: \(coordinates.longitude) for \(query)")
        }
        
        YelpService().fetchRestaurants(
            term: query,
            latitude: coordinates.latitude,
            longitude: coordinates.longitude
        ) { fetched in
            DispatchQueue.main.async {
                self.restaurants = fetched
            }
        }
    }
        
        
        
        
        func setAnnotations(query: String) async throws {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region
            
            let search = MKLocalSearch(request: request)
            if let results = try? await search.start() {
                let items = results.mapItems
                for item in items {
                    print("1...coordinate: ", item.placemark.coordinate)
                    print("2...name: ", item.name ?? "undefined")
                    print("3...item: ", item)
                    print("4...address: ", item.placemark.thoroughfare ?? "Undefined")
                }
            }
        }
    }
    
    

