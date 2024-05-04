//
//  TransactionsViewModel.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 4/30/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

import Foundation
import SwiftUI
import FirebaseAuth

class TransactionsViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var totalSpendThisMonth: Double = 0.0
    @Published var userAccountAggregateBalance: Double = 0.0
    @Published var graphData: [CategorySpend] = []
    @Published var spendComparison: Double = 0.0
    @Published var streakValue: Int = 0
    let apiConfig = ApiConfig()
    @Published var isBusy = false

    // Generic method to perform API requests
    func fetchData<T: Decodable>(from endpoint: String, completion: @escaping (T) -> Void) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        
        guard let url = URL(string: "\(apiConfig.baseUrl)/user/\(endpoint)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["user_id": userID]
        
        do {
            request.httpBody = try JSONEncoder().encode(payload)
            isBusy = true
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            
            DispatchQueue.main.async {
                completion(decodedResponse)
                self.isBusy = false
            }
        } catch {
            print("An error occurred: \(error)")
            self.isBusy = false
        }
    }

    func fetchTransactions() async {
        await fetchData(from: "get-transaction") { (response: APIResponse) in
            self.transactions = response.latest_transactions
            self.totalSpendThisMonth = response.total_spend_this_month
            self.userAccountAggregateBalance = response.total_balance
        }
    }

    func fetchGraphData() async {
        await fetchData(from: "get-category-spend-monthly") { (response: APIResponseCategoryGraph) in
            self.graphData = response.category_wise_spend
        }
    }

    func fetchComparison() async {
        await fetchData(from: "get-comparison-data") { (response: Comparison) in
            self.spendComparison = response.user_comparison
        }
    }

    func fetchStreakData() async {
        await fetchData(from: "get-streak-data") { (response: StreakData) in
            self.streakValue = response.streak_data
        }
    }
    
    func calculateAngles(for categories: [CategorySpend]) -> [Double] {
        let totalExpense = categories.reduce(0) { $0 + $1.total_expense }
        return categories.map { $0.total_expense / totalExpense * 360 }
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
    var total_balance: Double
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

