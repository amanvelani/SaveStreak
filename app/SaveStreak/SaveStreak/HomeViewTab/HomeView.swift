//
//  HomeView.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 3/11/24.
//

import SwiftUI

struct HomeView: View {
    let transactions: [Transaction] = [
        Transaction(place: "Coffee Shop", amount: "$5.99"),
        Transaction(place: "Grocery Store", amount: "$32.50"),
        Transaction(place: "Bookstore", amount: "$20.45"),
        Transaction(place: "Restaurant", amount: "$45.90")
    ]

    let spendByCategory: [SpendCategory] = [
        SpendCategory(category: "Food & Drinks", amount: "$150.30"),
        SpendCategory(category: "Groceries", amount: "$200.25"),
        SpendCategory(category: "Entertainment", amount: "$75.00"),
        SpendCategory(category: "Transport", amount: "$55.40")
    ]

    
    var body: some View {
        NavigationView {
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
                                Text("$1,234.56")
                                    .font(.title)
                            }
                        }
                        CardView {
                            VStack(alignment: .leading) {
                                Text("Recent Transactions")
                                    .font(.headline)
                                ForEach(transactions, id: \.place) { transaction in
                                    HStack {
                                        Text(transaction.place)
                                        Spacer()
                                        Text(transaction.amount)
                                    }
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
                                ForEach(spendByCategory, id: \.category) { category in
                                    HStack {
                                        Text(category.category)
                                        Spacer()
                                        Text(category.amount)
                                    }
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

      struct Transaction {
          let place: String
          let amount: String
      }

struct SpendCategory {
    let category: String
    let amount: String
}



#Preview {
    HomeView()
}
