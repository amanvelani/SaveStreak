//
//  StreakSettingsView.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 5/3/24.
//
import SwiftUI

struct StreakSettingsView: View {
    @StateObject var viewModel = StreakViewModel()
    @State private var showingConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundGradient().opacity(1.00).edgesIgnoringSafeArea(.all)// Set the gradient background first in the ZStack
                VStack {
                    Form {
                        Section {
                            Picker("Category", selection: $viewModel.selectedCategory) {
                                ForEach(viewModel.categories, id: \.self) {
                                    Text($0)
                                }
                            }
                            HStack {
                                Text("Amount")
                                TextField("Amount", text: $viewModel.amount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 10)
                            }
                        }
                        
                        Section {
                            Button("Save") {
                                viewModel.saveExpense {
                                    self.showingConfirmation = true
                                }
                            }
                            .buttonStyle(GradientButtonStyle())
                            .padding(.top, 20)
                        }
                    }
                }
                .navigationTitle("Streak Setting")
                .alert(isPresented: $showingConfirmation) {
                    Alert(
                        title: Text("Confirmation"),
                        message: Text("Streak Setting saved successfully."),
                        dismissButton: .default(Text("OK"))
                    )
                }.background(BackgroundGradient())
            }.background(BackgroundGradient())
        }
        .onAppear {
            viewModel.fetchCategories()
            viewModel.fetchExistingData()
        }
        .background(BackgroundGradient())
    }

    func feedback() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
    }
}

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.primary.opacity(0.6), Color.secondary]), startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
