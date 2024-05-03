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
	
}

struct Transaction: Identifiable, Codable {
	var id: String {name}
	let transaction_id: String
	let name: String
	let amount: Double
	let date: String
	let category: [String]
	let location: Location
	
	struct Location: Codable {
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

