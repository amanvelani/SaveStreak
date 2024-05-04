//
//  TransactionsViewModel.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 4/30/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

class TransactionsViewModel: ObservableObject {
	@Published var transactions: [Transaction] = []
	@Published var topCategories: [CategorySpend] = []
	@Published var totalSpendThisMonth: Double = 0.0
	@Published var graphData: [CategorySpend] = []
    @Published var spendComparison: Double = 0.0
    @Published var streakValue: Int = 0
	let apiConfig = ApiConfig()
	@Published var isBusy = false
		// Function to fetch transactions data from the API
	func fetchTransactions() {
		
		guard let userID = Auth.auth().currentUser?.uid else {
			print("No user is logged in.")
			return
		}
		guard let url = URL(string: "\(apiConfig.baseUrl)/user/get-transaction") else {
			print("Invalid URL")
			return
		}
		isBusy = true
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
			// Prepare the JSON data with the userID
		let payload = ["user_id": userID]
		guard let jsonData = try? JSONEncoder().encode(payload) else {
			print("Error: Unable to encode user_id into JSON")
			return
		}
		
		request.httpBody = jsonData
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
				return
			}
			
			do {
				let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)
				self.isBusy = false
				DispatchQueue.main.async {
					self.transactions = decodedResponse.latest_transactions
//					self.topCategories = decodedResponse.top_categories
					self.totalSpendThisMonth = decodedResponse.total_spend_this_month
				}
			} catch let jsonError {
				self.isBusy = false
				print("Failed to decode JSON: \(jsonError)")
			}
		}.resume()
	}
	
	func fetchGraphData(){
		guard let userID = Auth.auth().currentUser?.uid else {
			print("No user is logged in.")
			return
		}
		guard let url = URL(string: "\(apiConfig.baseUrl)/user/get-category-spend-monthly") else {
			print("Invalid URL")
			return
		}
		
		isBusy = true
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
			// Prepare the JSON data with the userID
		let payload = ["user_id": userID]
		guard let jsonData = try? JSONEncoder().encode(payload) else {
			print("Error: Unable to encode user_id into JSON")
			return
		}
		
		request.httpBody = jsonData
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
				return
			}
			
			do {
				let decodedResponse = try JSONDecoder().decode(APIResponseCategoryGraph.self, from: data)
				self.isBusy = false
				DispatchQueue.main.async {
					self.graphData = decodedResponse.category_wise_spend
				}
			} catch let jsonError {
				self.isBusy = false
				print("Failed to decode JSON: \(jsonError)")
			}
		}.resume()
	}
	
	func calculateAngles(for categories: [CategorySpend]) -> [Double] {
		let totalExpense = categories.reduce(0) { $0 + $1.total_expense }
		return categories.map { $0.total_expense / totalExpense * 360 }
	}
    
    func fetchComparison() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        
        do {
            
            let url = URL(string: "\(apiConfig.baseUrl)/user/get-comparison-data")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let requestBody = ["user_id": userId]
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(Comparison.self, from: data)
            
            // Process the fetched account data
            self.spendComparison = response.user_comparison
        } catch {
            print("An error occurred: \(error)")
        }
    }
	
	func fetchStreakData(){
		guard let userID = Auth.auth().currentUser?.uid else {
			print("No user is logged in.")
			return
		}
		guard let url = URL(string: "\(apiConfig.baseUrl)/user/get-streak-data") else {
			print("Invalid URL")
			return
		}
		
		isBusy = true
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
			// Prepare the JSON data with the userID
		let payload = ["user_id": userID]
		guard let jsonData = try? JSONEncoder().encode(payload) else {
			print("Error: Unable to encode user_id into JSON")
			return
		}
		
		request.httpBody = jsonData
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
				return
			}
			
			do {
				let decodedResponse = try JSONDecoder().decode(StreakData.self, from: data)
				DispatchQueue.main.async {
					self.streakValue = decodedResponse.streak_data
				}
			} catch let jsonError {
				print("Failed to decode JSON: \(jsonError)")
			}
		}.resume()
	}
	
}

struct Transaction: Identifiable, Codable, Equatable {
	var id: String {name}
	let transaction_id: String
	let name: String
	let amount: Double
	let date: String
	let category: [String]
	let location: Location
	
	struct Location: Codable, Equatable {
		let address: String
		let city: String
		let country: String
		let lat: Double
		let lon: Double
		let postal_code: String
		let region: String
		let store_number: String
	}
	var displayName: String {
		name.components(separatedBy: ". Merchant name:").first ?? name
	}
    // Conforming to Equatable manually if needed
        static func == (lhs: Transaction, rhs: Transaction) -> Bool {
            lhs.transaction_id == rhs.transaction_id &&
            lhs.name == rhs.name &&
            lhs.amount == rhs.amount &&
            lhs.date == rhs.date &&
            lhs.category == rhs.category &&
            lhs.location == rhs.location
        }
        
        enum CodingKeys: String, CodingKey {
            case transaction_id
            case name
            case amount
            case date
            case category
            case location
        }
}

struct CategorySpend: Identifiable, Codable, Equatable, Hashable {
	var id: String { _id }
	let _id: String
	let total_expense: Double
}

struct SpendTrend: Identifiable, Codable, Equatable, Hashable {
	var id: String { _id }
	let _id: String
	let total_spending: Double
}

struct APIResponse: Codable {
	var latest_transactions: [Transaction]
//	var top_categories: [CategorySpend]
	var total_spend_this_month: Double
}


struct APIResponseCategoryGraph: Codable {
	var category_wise_spend: [CategorySpend]
}

struct APIResponseTrendGraph: Codable {
	var spending_trend: [SpendTrend]
}

struct Comparison: Codable {
    let user_comparison: Double
}

struct StreakData: Codable {
    let streak_data: Int
}

