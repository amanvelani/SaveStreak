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

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isBusy {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                } else {
                    ZStack {
                        BackgroundGradient()
                        contentScrollView
                    }
                }
            }
//            .navigationBarTitle("Save Streak", displayMode: .inline)
            .onAppear {
                
                Task {
                    await viewModel.fetchTransactions()
                    await viewModel.fetchStreakData()
                    await viewModel.fetchComparison()
					
                }
            }
        }
    }

    private var contentScrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                statsHeader
                spendingCard
                transactionList
                communityInsightsCard
            }
            .padding([.horizontal, .bottom])
        }
        .onAppear(){
            OrientationManager.shared.updateOrientation(.all)
        }
        .animation(.easeInOut, value: viewModel.transactions)
    }

    private var statsHeader: some View {
        HStack {
            Image("homeScreen")
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50) // Smaller size
            .clipShape(Circle())
            Text("SaveStreak")
                .font(.title) // Using a bold and heavy system font
                .foregroundColor(Color.green) // Text color
                .shadow(color: .gray, radius: 1, x: 0, y: 2) // Subtle shadow for depth
                .padding(.vertical, 10)
            Spacer()
            Image(systemName: "leaf.fill")
                .imageScale(.large)
                .foregroundColor(.green)
                .frame(width: 50, height: 50)
			Text("\(viewModel.streakValue)")
                .font(.title)
                .bold()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }

    private var spendingCard: some View {
        CardView {
            VStack(alignment: .leading) {
                Text("Total Spends")
                    .font(.headline)
                    .foregroundColor(.red)  // Make text red
                Text("$\(viewModel.totalSpendThisMonth, specifier: "%.2f")")
                    .font(.title)  // Change from .largeTitle to .title to make text smaller
                    .fontWeight(.bold)
                    .foregroundColor(.red)  // Make text red
                Spacer().frame(height: 20) // Add spacer to increase length
                Text("Total Balance")
                    .font(.headline)
                    .foregroundColor(.green)  // Make text green
                Text("$\(viewModel.userAccountAggregateBalance, specifier: "%.2f")")
                    .font(.title)  // Change from .largeTitle to .title to make text smaller
                    .fontWeight(.bold)
                    .foregroundColor(.green)  // Make text green
            }
            .padding(.horizontal, 10)  // Reduce horizontal padding to make it thinner
            .frame(minWidth: 0, maxWidth: .infinity)  // Ensure it takes full width available
        }
        .padding(.horizontal, 20)  // Optionally adjust padding around the card to fit your UI design
    }


    private var transactionList: some View {
        CardView {
            VStack(alignment: .leading) {
                Text("Recent Transactions")
                    .font(.headline)

                ForEach(viewModel.transactions.prefix(5), id: \.id) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
            Spacer()
            NavigationLink(destination: AllTransactionsView(viewModel: viewModel) ) {
                HStack {
					
                    Spacer()
					Text("See All Transactions")
                    Image(systemName: "chevron.right.circle")
                        .foregroundColor(.blue)
                }
                
            }
        }
    }

    private var communityInsightsCard: some View {
        CardView {
            VStack(alignment: .leading) {
                Text("Community Spending Insights")
                    .font(.headline)

                if viewModel.spendComparison > 0 {
                    Text("You have spent $\(abs(viewModel.spendComparison), specifier: "%.2f") less than other users using this app in the last month.")
                        .font(.subheadline)
                } else if viewModel.spendComparison < 0 {
                    Text("You have spent $\(abs(viewModel.spendComparison), specifier: "%.2f") more than other users using this app in the last month.")
                        .font(.subheadline)
                } else {
                    Text("Your spending matches the average of other users using this app.")
                        .font(.subheadline)
                }
            }
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Text(transaction.displayName)
                .font(.headline)
                .foregroundColor(.primary)
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
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(0.3), // Soft Green
                Color(red: 0.980, green: 0.980, blue: 0.824).opacity(0.3), // Pale Cream
                Color.white.opacity(0.3) // White
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
}
