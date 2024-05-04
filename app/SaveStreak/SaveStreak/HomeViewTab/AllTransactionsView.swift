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
                AllTransactionRow(transaction: transaction)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Transactions")
            .toolbar {
                Button(action: {
                    showingFilters.toggle()
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
            }
            .searchable(text: $searchText, prompt: "Search Transactions")

            .background(BackgroundGradient())
        }
    }
}

struct AllTransactionRow: View {
    var transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(transaction.displayName)
                .font(.headline)
                .foregroundColor(.primary)
            HStack {
                Text(transaction.date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                Spacer()
                Text("$\(transaction.amount, specifier: "%.2f")")
                    .font(.title3)
                    .bold()
            }
            Text("\(transaction.location.city), \(transaction.location.country)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
