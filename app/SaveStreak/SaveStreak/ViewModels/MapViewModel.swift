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

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: MKCoordinateRegion
    @Published var locationTransactions: [LocationTransaction] = []
    @Published var isBusy = false
    @Published var selectedCategory = "All"
    @Published var selectedDateRange = "Past Week"
    let categories = ["All", "Bank Fees", "Cash Advance", "Community", "Food and Drink", "Healthcare", "Interest", "Payment", "Recreation", "Service", "Shops"]
    let dateRanges = ["Past Week", "Past Month"]
    let apiConfig = ApiConfig()
    private var locationManager: CLLocationManager?

    override init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.distanceFilter = 10

        // Check the authorization status before updating the location
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.global(qos: .background).async {
                self.locationManager?.startUpdatingLocation()
            }
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location services are denied/restricted. Please enable them in settings.")
        @unknown default:
            print("A new case was added that we need to handle")
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationManager?.startUpdatingLocation()
            } else {
                print("Location services are not enabled.")
            }
        case .denied, .restricted:
            print("Location services are denied/restricted. Please enable them in settings.")
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        @unknown default:
            print("A new case was added that we need to handle")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let newRegion = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        DispatchQueue.main.async {
            self.region = newRegion
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }


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

