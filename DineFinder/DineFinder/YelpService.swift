//
//  YelpService.swift
//  CourseworkProofOConcept
//
//  Created by Ana 😋 on 15/04/2025.
//
import Foundation

class YelpService {
    private let apiKey = "PFP5Cft4iAUmDUSzGiSdjO4hLEaxHqQ1D5feYde3ZrSS1DbkJfo5Ye48yeaRkppsaLHP43tJnLknxqQK_Ln8gpFU3HwSSbQIZ2nd81b_FbF35S5bdRCkTxL5yoz-Z3Yx" 

    func fetchRestaurants(term: String, latitude: Double, longitude: Double, completion: @escaping ([Business]) -> Void) {
        let urlString = "https://api.yelp.com/v3/businesses/search?term=\(term)&latitude=\(latitude)&longitude=\(longitude)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let yelpResponse = try JSONDecoder().decode(YelpResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(yelpResponse.businesses)
                    }
                } catch {
                    print("Decoding error:", error)
                }
            } else if let error = error {
                print("Network error:", error)
            }
        }.resume()
    }
}
