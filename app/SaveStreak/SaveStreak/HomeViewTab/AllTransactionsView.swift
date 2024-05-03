//
//  AllTransactionsView.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 5/3/24.
//

import SwiftUI

struct AllTransactionsView: View {
	@ObservedObject var viewModel: TransactionsViewModel
	@State private var showingFilters = false
	@State private var searchText: String = ""
	
		// Filtered transactions based on search text
	private var filteredTransactions: [Transaction] {
		if searchText.isEmpty {
			return viewModel.transactions
		} else {
			return viewModel.transactions.filter { transaction in
				transaction.name.localizedCaseInsensitiveContains(searchText) ||
				transaction.category.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) ||
				transaction.location.city.localizedCaseInsensitiveContains(searchText) ||
				transaction.location.country.localizedCaseInsensitiveContains(searchText)
			}
		}
	}
	
	var body: some View {
		NavigationView {
			List(filteredTransactions) { transaction in
				VStack(alignment: .leading) {
					Text(transaction.displayName)
						.font(.headline)
					Text(transaction.date)
						.font(.subheadline)
					Text("$\(transaction.amount, specifier: "%.2f")")
						.font(.body)
					Text(transaction.location.city + ", " + transaction.location.country)
						.font(.caption)
				}
			}
			.navigationTitle("Transactions")
			.searchable(text: $searchText, prompt: "Search Transactions")
		}
		
	}
}
