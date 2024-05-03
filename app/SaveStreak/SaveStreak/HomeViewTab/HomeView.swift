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
                viewModel.fetchTransactions()
                Task {
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
                .font(.headline) // Using a bold and heavy system font
                .foregroundColor(Color.green) // Text color
                .shadow(color: .gray, radius: 1, x: 0, y: 2) // Subtle shadow for depth
                .padding(.vertical, 10)
            Spacer()
            Image(systemName: "leaf.fill")
                .imageScale(.large)
                .foregroundColor(.green)
                .frame(width: 50, height: 50)
            Text("5")
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
                Text("$\(viewModel.totalSpendThisMonth, specifier: "%.2f")")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
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
                    Text("You have spent $\(abs(viewModel.spendComparison), specifier: "%.2f") more than other users using this app.")
                        .font(.subheadline)
                } else if viewModel.spendComparison < 0 {
                    Text("You have spent $\(abs(viewModel.spendComparison), specifier: "%.2f") less than other users using this app.")
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
                Color.green.opacity(0.18),
                Color.blue.opacity(0.4)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
}

