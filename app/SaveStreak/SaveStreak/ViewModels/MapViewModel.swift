//
//  MapViewModel.swift
//  SaveStreak
//
//  Created by Aman Velani on 5/2/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import CoreLocation
import MapKit
import LocationProvider
import Combine
import UIKit

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate  {
//    @Published var region: MKCoordinateRegion
    @Published var locationTransactions: [LocationTransaction] = []
    @Published var isBusy = false
    @Published var selectedCategory = "All"
    @Published var selectedDateRange = "Past Week"
    let categories = ["All", "Bank Fees", "Cash Advance", "Community", "Food and Drink", "Healthcare", "Interest", "Payment", "Recreation", "Service", "Shops"]
    let dateRanges = ["Past Week", "Past Month"]
    let apiConfig = ApiConfig()
    @Published var region: MKCoordinateRegion
        private var locationManager = CLLocationManager()
    private var isInitialRegionSet = false

        
    override init() {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 43.037432, longitude: -76.121801),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            setupLocationManager()
        }
        
        private func setupLocationManager() {
            locationManager.requestWhenInUseAuthorization() // or requestAlwaysAuthorization() if necessary
        }
    
    func startLocationUpdates() {
            locationManager.startUpdatingLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .notDetermined:
                print("In Not determined")
                manager.requestWhenInUseAuthorization()
                // Wait for user decision on permission
                break
            case .restricted, .denied:
                // Handle the case where the user has denied/restricted location services
                print("Location permission not granted")
            case .authorizedWhenInUse, .authorizedAlways:
                // Start location updates
                locationManager.startUpdatingLocation()
            @unknown default:
                // Handle future status cases
                fatalError("Unhandled authorization status: \(status)")
            }
        }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updated locations: \(locations)")
        if let newLocation = locations.last {
            DispatchQueue.main.async { // Ensure UI updates on the main thread
                if !self.isInitialRegionSet {
                    self.isInitialRegionSet = true
                    self.region = MKCoordinateRegion(
                        center: newLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }
    
    func faillocationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func changelocationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed: \(status)")
    }
//    func requestLocation() {
//           locationManager.requestLocation()
//       }
    func fetchTransactions() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        let endDate = Date()
        let startDate = selectedDateRange == "Past Week" ? Calendar.current.date(byAdding: .weekOfYear, value: -1, to: endDate)! : Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let url = URL(string: "\(apiConfig.baseUrl)/user/get-transaction-by-location") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["user_id": userID, "category": selectedCategory, "start_date": formatter.string(from: startDate), "end_date": formatter.string(from: endDate)]
        request.httpBody = try? JSONEncoder().encode(payload)

        isBusy = true
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer { self?.isBusy = false }
            guard let data = data, error == nil else {
                print("Network request failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let response = try? JSONDecoder().decode(TransactionsResponse.self, from: data) {
                DispatchQueue.main.async {
                    self?.locationTransactions = response.transactions
                }
            } else {
                print("Failed to decode response")
            }
        }.resume()
    }
}

struct LocationTransaction: Identifiable, Codable {
    var id: UUID { UUID() }
    let name: String
    let amount: Double
    let lat: Double
    let lon: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
struct TransactionsResponse: Codable {
    let transactions: [LocationTransaction]
}

class LocationProvider: NSObject, CLLocationManagerDelegate, ObservableObject{
    let locationManager = CLLocationManager()
    let locationUpdated = PassthroughSubject<CLLocation, Never>()

    func start() throws {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationUpdated.send(location)
        }
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}
