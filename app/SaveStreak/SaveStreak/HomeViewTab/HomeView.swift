	//
	//  HomeView.swift
	//  SaveStreak
	//
	//  Created by Chinmay Yadav on 3/11/24.
	//

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var apiConfig: ApiConfig
	
	@StateObject var viewModel = TransactionsViewModel()
		//    let transactions: [Transaction] = [
		//        Transaction(place: "Coffee Shop", amount: "$5.99"),
		//        Transaction(place: "Grocery Store", amount: "$32.50"),
		//        Transaction(place: "Bookstore", amount: "$20.45"),
		//        Transaction(place: "Restaurant", amount: "$45.90")
		//    ]
	
	let spendByCategory: [SpendCategory] = [
		SpendCategory(category: "Food & Drinks", amount: "$150.30"),
		SpendCategory(category: "Groceries", amount: "$200.25"),
		SpendCategory(category: "Entertainment", amount: "$75.00"),
		SpendCategory(category: "Transport", amount: "$55.40")
	]
	
	
	var body: some View {
		NavigationView {
			VStack {
				if(viewModel.isBusy){
					ProgressView()
				} else{
					ZStack {
						LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
							.edgesIgnoringSafeArea(.all)
						
						ScrollView {
							VStack (spacing: 10){
								HStack {
									Image(systemName: "network")
										.scaledToFit()
										.frame(width: 50, height: 50)
									Spacer()
									Image(systemName: "tree")
										.scaledToFit()
										.frame(width: 50, height: 50)
									Text("5")
								}
								.padding()
								
								CardView {
									VStack(alignment: .leading) {
										Text("Total Spends")
											.font(.headline)
										Text("$\(viewModel.totalSpendThisMonth, specifier: "%.2f")")
											.font(.title)
									}
								}
								CardView {
									VStack(alignment: .leading) {
										Text("Recent Transactions")
											.font(.headline)
										
										ForEach(Array(viewModel.transactions.prefix(5))) { transaction in
											HStack {
													//												VStack(alignment: .leading) {
												Text(transaction.displayName)
													.font(.headline)
													.foregroundColor(.primary) // Use dynamic color for light/dark mode support
													//													Text(transaction.category.joined(separator: ", "))
													//														.font(.subheadline)
													//														.foregroundColor(.secondary)
													//												}
												Spacer()
												VStack(alignment: .trailing) {
													Text("$\(transaction.amount, specifier: "%.2f")")
														.font(.title2)
														.foregroundColor(transaction.amount < 0 ? .red : .green)
													Text(transaction.date)
														.font(.footnote)
														.foregroundColor(.secondary)
												}
											}
											.padding()
											.background(Color(UIColor.systemBackground)) // Adds subtle background; adapt for light/dark mode
											.clipShape(RoundedRectangle(cornerRadius: 10))
											.shadow(radius: 2) // Adds a slight shadow for depth
										}
										
										
										Spacer()
										HStack {
											Spacer()
											Image(systemName: "chevron.right.circle")
												.foregroundColor(.blue)
												.onTapGesture {
														// Action to expand into a detailed page
												}
										}
									}
								}
								
									// Section 3: Spend by Category
								CardView {
									VStack(alignment: .leading) {
										Text("Spend by Category")
											.font(.headline)
										
										
										ForEach(Array(viewModel.topCategories.prefix(5))) { category in
											HStack {
												VStack(alignment: .leading) {
													Text(category._id)
														.font(.headline) // Larger font for category name
														.foregroundColor(Color.blue) // Distinct color for category
														//													Text("Top Spending")
														//														.font(.subheadline)
														//														.foregroundColor(.gray) // Subdued color for descriptive text
												}
												Spacer()
												VStack(alignment: .trailing) {
													Text("$\(category.total_expense, specifier: "%.2f")")
														.font(.title2) // Larger, bold font for the amount
														.foregroundColor(.primary) // Use primary to adapt to dark/light mode
												}											}
										}
									}
									
									
								}
								
									// Section 4: Spend Comparison by Occupation
								
								CardView {
									VStack(alignment: .leading) {
										Text("Comparison by Occupation")
											.font(.headline)
											// Using HStack to ensure horizontal alignment
											// and VStack for vertical alignment if needed.
										HStack {
												// Wrap the concatenated Text views in a VStack if you need vertical alignment,
												// otherwise just concatenate them directly.
											VStack(alignment: .leading) { // Ensures alignment for multiline text
												(Text("Your spend is on an average ") + Text("$450").bold() + Text(" more monthly compared to other Students"))
													.font(.subheadline) // Apply the font to the entire Text sequence
											}
										}
									}
								}
								
							}
							.padding([.horizontal, .bottom])
							.navigationBarTitle(Text("Save Streak"), displayMode: .inline)
							
						}
					}
				}
			}
		}.onAppear {
			viewModel.fetchTransactions()
		}
	}
}

struct CardView<Content: View>: View {
	let content: Content
	
	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			content
		}
		.padding()
		.frame(minWidth: 0, maxWidth: .infinity)
		.background(Color.white.opacity(0.8)) // Slightly transparent to blend with the background
		.cornerRadius(10)
		.shadow(radius: 5)
		.padding([.top, .horizontal])
	}
}

	//      struct Transaction {
	//          let place: String
	//          let amount: String
	//      }

struct SpendCategory {
	let category: String
	let amount: String
}


	//
	//	#Preview {
	//		HomeView()
	//	}
