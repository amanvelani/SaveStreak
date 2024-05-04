//
//  StreakSettingsView.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 5/3/24.
//
import SwiftUI

struct StreakSettingsView: View {
    @StateObject var viewModel = StreakViewModel()
    
    var body: some View {
        NavigationView {
            VStack{
                Form {
                    Section {
                        Picker("Category", selection: $viewModel.selectedCategory) {
                            ForEach(viewModel.categories, id: \.self) {
                                Text($0).foregroundColor(Color.primary) // Dynamic color for text
                            }
                        }
                        HStack {
                            Text("Amount").foregroundColor(Color.primary) // Dynamic color for text
                            TextField("Amount", text: $viewModel.amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 10)
                        }
                    }
                    
                    Section {
                        Button(action: {
                            viewModel.saveExpense()
                            feedback()
                        }) {
                            Text("Save")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GradientButtonStyle())
                        .padding(.top, 20)
                    }
                }
                .navigationTitle("Streak Setting")
                .onAppear {
                    viewModel.fetchCategories()
                    viewModel.fetchExistingData()
                }
            }
            .background(BackgroundGradient())
            .edgesIgnoringSafeArea(.all)
        }.background(BackgroundGradient())
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
