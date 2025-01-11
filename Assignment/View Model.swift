//
//  View Model.swift
//  Assignment
//
//  Created by Sambhav Singh on 11/01/25.
//

import Foundation
import SwiftUI


import Foundation
import SwiftUI
class DietPlanViewModel: ObservableObject {
    
    @Published var diets: [Diet] = []
    @Published var dietStreak: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let apiURL = "https://uptodd.com/fetch-all-diets"
    private var urlSession: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.waitsForConnectivity = true
        self.urlSession = URLSession(configuration: configuration)
    }
    
    func fetchDiets() {
        print("Starting fetch...")
        guard let url = URL(string: apiURL) else {
            print("Invalid URL: \(apiURL)")
            errorMessage = "Invalid URL"
            return
        }
        isLoading = true
        print("Set loading to true")
        errorMessage = nil
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            print("Received response from API")
            
            DispatchQueue.main.async {
                defer {
                    self?.isLoading = false
                    print("Set loading to false")
                }
                
                if let error = error {
                    print("Network error: \(error)")
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    self?.errorMessage = "Invalid server response"
                    return
                }
                
                print("HTTP Status Code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Bad HTTP response: \(httpResponse.statusCode)")
                    self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    self?.errorMessage = "No data received"
                    return
                }
                
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON: \(jsonString)")
                    }
                    
                    let decodedResponse = try JSONDecoder().decode(DietResponse.self, from: data)
                    print("Successfully decoded response")
                    self?.dietStreak = decodedResponse.data.diets.dietStreak
                    self?.diets = decodedResponse.data.diets.allDiets
                    print("Updated model: \(decodedResponse.data.diets.allDiets.count) diets")
                } catch {
                    print("Decoding error: \(error)")
                    self?.errorMessage = "Failed to decode data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
}
