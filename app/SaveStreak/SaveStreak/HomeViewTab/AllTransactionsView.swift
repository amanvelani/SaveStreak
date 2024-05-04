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
	@State private var showingDetail = false
	@State private var selectedTransaction: Transaction?
	
	
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
			List(filteredTransactions, id: \.id) { transaction in
				AllTransactionRow(transaction: transaction)
					.onLongPressGesture {
						self.selectedTransaction = transaction
					}
			}
			.onChange(of: selectedTransaction) { _ in
				if selectedTransaction != nil {
					showingDetail = true
				}
			}
			.onChange(of: showingDetail) { _ in
				if showingDetail == false {
					selectedTransaction = nil
				}
			}			
			.listStyle(InsetGroupedListStyle())
			.navigationTitle("Transactions")
				//            .toolbar {
				//                Button(action: {
				//                    showingFilters.toggle()
				//                }) {
				//                    Image(systemName: "line.horizontal.3.decrease.circle")
				//                }
				//            }
			.searchable(text: $searchText, prompt: "Search Transactions")
			.background(BackgroundGradient())
			.sheet(isPresented: $showingDetail) {
				if let transaction = self.selectedTransaction {
					TransactionDetailView(transaction: transaction)
				}
			}
			
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


struct TransactionDetailView: View {
	var transaction: Transaction
	
	var body: some View {
		ScrollView {
			Spacer()
			VStack(alignment: .leading) {
				Text("Transaction Details")
					.font(.largeTitle)
					.fontWeight(.heavy)
					.foregroundColor(Color.blue)
					.padding(.vertical)
				
				VStack (alignment: .leading, spacing: 8){
					detailLabel(title: "Transaction ID", value: transaction.transaction_id)
				}
				
				
				Divider()
				
				HStack {
					VStack(alignment: .leading, spacing: 8) {
						detailLabel(title: "Name", value: transaction.displayName)
						detailLabel(title: "Date", value: transaction.date)
					}
					
					Spacer()
					
					VStack(alignment: .leading, spacing: 8) {
						detailLabel(title: "Amount", value: String(format: "$%.2f", transaction.amount))
						detailLabel(title: "Categories", value: transaction.category.joined(separator: ", "))
					}
				}
				
				Text("Location")
					.font(.headline)
					.padding(.top)
				
				Text("\(transaction.location.address), \(transaction.location.city), \(transaction.location.region), \(transaction.location.postal_code), \(transaction.location.country)")
					.font(.footnote)
					.foregroundColor(.secondary)
					.padding(.bottom)
				
				Spacer()
			}
			.padding()
			.background(Color(.systemBackground))
			.cornerRadius(12)
			.shadow(radius: 5)
			.padding()
			Spacer()
		}
		.background(BackgroundGradient())
		.edgesIgnoringSafeArea(.all)
	}
	
	@ViewBuilder
	private func detailLabel(title: String, value: String) -> some View {
		VStack(alignment: .leading) {
			Text(title.uppercased())
				.font(.caption)
				.fontWeight(.bold)
				.foregroundColor(.gray)
			Text(value)
				.font(.body)
				.foregroundColor(.primary)
		}
	}
	
}

