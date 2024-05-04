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
		self.categories = ["Bank Fees","Cash Advance","Community","Food and Drink","Healthcare","Interest","Payment","Recreation","Service","Shops"]
	}
	
	func fetchExistingData() {
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
		
		do {
			let encoded = try encoder.encode(requestBody)
			request.httpBody = encoded
			URLSession.shared.dataTask(with: request) { data, response, error in
				if let error = error {
					print("Network request failed: \(error)")
					return
				}
				
				guard let data = data else {
					print("No data received")
					return
				}
				
				do {
					let decoder = JSONDecoder()
					let decodedExpense = try decoder.decode(APIResponseStreak.self, from: data)
					DispatchQueue.main.async {
						self.selectedCategory = decodedExpense.streak_category
						self.amount = decodedExpense.streak_target
					}
				} catch {
					print("Failed to decode expense: \(error)")
				}
			}.resume()
		} catch {
			print("Failed to encode request: \(error)")
		}

	}
	func saveExpense(completion: @escaping () -> Void) {
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
				_ = try JSONDecoder().decode(ApiResponseStatus.self, from: data)
				DispatchQueue.main.async {
					completion() // Call the completion handler
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
	var streak_target: String
}


struct ApiResponseStatus: Codable {
	var status: String
	var error: String?
	
	enum CodingKeys: String, CodingKey {
		case status = "status"
		case error = "error"
	}
}
