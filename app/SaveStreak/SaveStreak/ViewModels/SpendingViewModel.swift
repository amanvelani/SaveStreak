	//
	//  SpendingViewModel.swift
	//  SaveStreak
	//
	//  Created by Chinmay Yadav on 5/2/24.
	//

import Foundation
import Combine
import FirebaseAuth

class SpendingViewModel: ObservableObject {
	@Published var categoryWiseSpend: [CategorySpend] = []
	@Published var trendSpendData: [SpendTrend] = []
		//	@Published var filteredData: [Spend] = []
	@Published var isBusy = false
	let apiConfig = ApiConfig()
	
	private var cancellables = Set<AnyCancellable>()
	var rawSelection: Double?
	private(set) var selectedCountry: CategorySpend?
	var categoryRanges: [(_id: String, range: Range<Double>)] = []
	var totalPosts: Double = 0.0
	
	
	
	var selectedItem: CategorySpend?
	
	
	func loadCategoryData() {
			// Fetch data here and assign it to `spendData`
		self.isBusy = true
		guard let userID = Auth.auth().currentUser?.uid else {
			print("No user is logged in.")
			return
		}
		guard let url = URL(string: "\(apiConfig.baseUrl)/user/get-category-spend-monthly") else {
			print("Invalid URL")
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
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
					self.categoryWiseSpend = decodedResponse.category_wise_spend
					self.updateMetaData()
				}
				
				
			} catch let jsonError {
				self.isBusy = false
				print("Failed to decode JSON: \(jsonError)")
			}
		}.resume()
	}
	
	func loadSpendingTrendData() {
		self.isBusy = true
		guard let userID = Auth.auth().currentUser?.uid else {
			print("No user is logged in.")
			return
		}
		guard let url = URL(string: "\(apiConfig.baseUrl)/user/get-spending-trend") else {
			print("Invalid URL")
			return
		}
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
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
				let decodedResponse = try JSONDecoder().decode(APIResponseTrendGraph.self, from: data)
				
				DispatchQueue.main.async {
					self.isBusy = false
					self.trendSpendData = decodedResponse.spending_trend
					print(self.trendSpendData)
						//					self.updateMetaData()
				}
				
				
			} catch let jsonError {
				self.isBusy = false
				print("Failed to decode JSON: \(jsonError)")
			}
		}.resume()
	}
	
	func updateMetaData() {
		var total = 0.0
		self.categoryRanges = self.categoryWiseSpend.map {
			let newTotal = total + $0.total_expense
			let result = (_id: $0._id,
						  range: Double(total) ..< Double(newTotal))
			total = newTotal
			return result
		}
		self.totalPosts = total
		
	}
	
	
	func filterData(startDate: Date, endDate: Date, isCategory: Bool = true) {
		guard let url = URL(string: "\(apiConfig.baseUrl)/user/get-category-spend-custom-date-range") else {
				//			completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
			print("Invalid URL")
			return
		}
		
		guard let userID = Auth.auth().currentUser?.uid else {
			print("No user is logged in.")
			return
		}
		
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
		
		let formattedStartDate = dateFormatter.string(from: startDate)
		let formattedEndDate = dateFormatter.string(from: endDate)
		
		let jsonBody: [String: Any] = [
			"start_date": formattedStartDate,
			"end_date": formattedEndDate,
			"user_id": userID
		]
		
		do {
			self.isBusy = true
			let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
			
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.httpBody = jsonData
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			
			URLSession.shared.dataTask(with: request) { data, response, error in
				guard let data = data, error == nil else {
					self.isBusy = false
					print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
					return
				}
				
				do {
					let decodedResponse = try JSONDecoder().decode(APIResponseCategoryGraph.self, from: data)
					self.isBusy = false
					DispatchQueue.main.async {
						self.categoryWiseSpend = decodedResponse.category_wise_spend
						self.updateMetaData()
					}
					
					
				} catch let jsonError {
					self.isBusy = false
					print("Failed to decode JSON: \(jsonError)")
				}
			}.resume()
		} catch {
				//			completion(.failure(error))
		}
		
	}
	
	func clearFilters(){
		
	}
	
	func filterSpendData(startMonth: DateComponents, endMonth: DateComponents){
		self.isBusy = true
		guard let url = URL(string: "\(apiConfig.baseUrl)/user/get-custom-spending-trend") else {
				//			completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
			print("Invalid URL")
			return
		}
		
		guard let userID = Auth.auth().currentUser?.uid else {
			print("No user is logged in.")
			return
		}
		
//		let dateFormatter = ISO8601DateFormatter()
//		dateFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
		
//		let formattedStartDate = dateFormatter.string(from: startDate)
//		let formattedEndDate = dateFormatter.string(from: endDate)
		
		let jsonBody: [String: Any] = [
			"start_month": startMonth.month!,
			"end_month": endMonth.month!,
			"user_id": userID
		]
		
		do {
			self.isBusy = true
			let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
			
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.httpBody = jsonData
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			
			URLSession.shared.dataTask(with: request) { data, response, error in
				guard let data = data, error == nil else {
					self.isBusy = false
					print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
					return
				}
				
				do {
					let decodedResponse = try JSONDecoder().decode(APIResponseTrendGraph.self, from: data)
					self.isBusy = false
					DispatchQueue.main.async {
						self.trendSpendData = decodedResponse.spending_trend
					}
					
					
				} catch let jsonError {
					self.isBusy = false
					print("Failed to decode JSON: \(jsonError)")
				}
			}.resume()
		} catch {
		}
	}
	
}

