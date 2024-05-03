//
//  StreakViewModel.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 5/3/24.
//

import Foundation

import SwiftUI
import FirebaseAuth

struct ExpenseEntry: Codable {
	var userID: String
	var category: String
	var amount: Double
}

class StreakViewModel: ObservableObject {
	@Published var categories: [String] = []
	@Published var selectedCategory: String = ""
	@Published var amount: String = ""
	let apiConfig = ApiConfig()
	
	func fetchCategories() {
			// Mock fetching from backend
			// Replace this with your actual network request
		self.categories = ["Bank Fees","Cash Advance","Community","Food and Drink","Healthcare","Interest","Payment","Recreation","Service","Shops"]
	}
	
	func fetchExistingExpense() {
			// Use POST method and include user ID in the request
		guard let userID = Auth.auth().currentUser?.uid else {
			print("No user is logged in.")
			return
		}
		let url = URL(string: "\(apiConfig.baseUrl)/user/get-streak-category")!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		let requestBody = ["user_id": userID]
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(requestBody) {
			request.httpBody = encoded
			URLSession.shared.dataTask(with: request) { data, response, error in
				if let data = data {
					let decoder = JSONDecoder()
					if let decodedExpense = try? decoder.decode(ExpenseEntry.self, from: data) {
						DispatchQueue.main.async {
							self.selectedCategory = decodedExpense.category
							self.amount = String(decodedExpense.amount)
						}
					}
				}
			}.resume()
		}
	}
	func saveExpense() {
		guard let userID = Auth.auth().currentUser?.uid else {
			print("No user is logged in.")
			return
		}
		guard let url = URL(string: "\(apiConfig.baseUrl)/user/set-streak-category") else {
			print("Invalid URL")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
			// Prepare the JSON data with the userID
		let payload = ["user_id": userID, "category": selectedCategory, "target": amount]
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
				let decodedResponse = try JSONDecoder().decode(APIResponseStreak.self, from: data)
				DispatchQueue.main.async {
				}
			} catch let jsonError {
				print("Failed to decode JSON: \(jsonError)")
			}
		}.resume()
	}
}


struct APIResponseStreak: Codable {
	var streak_category: String
		//	var top_categories: [CategorySpend]
	var streak_target: Double
}
