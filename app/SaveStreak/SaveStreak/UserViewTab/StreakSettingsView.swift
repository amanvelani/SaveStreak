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
			Form {
				Section() {
					Picker("Category", selection: $viewModel.selectedCategory) {
						ForEach(viewModel.categories, id: \.self) {
							Text($0)
						}
					}
//					.pickerStyle(SegmentedPickerStyle())
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
								// This completion handler will be triggered after the network call.
							self.showingConfirmation = true
						}
					}
					.buttonStyle(GradientButtonStyle())
					.padding(.top, 20)
				}
			}
			.navigationTitle("Streak Setting")
			.alert(isPresented: $showingConfirmation) {
				Alert(
					title: Text("Confirmation"),
					message: Text("Streak Setting saved successfully."),
					dismissButton: .default(Text("OK"))
				)
			}

			.onAppear {
				viewModel.fetchCategories()
				viewModel.fetchExistingData()
			}
		}
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
			.background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
			.foregroundColor(.white)
			.clipShape(RoundedRectangle(cornerRadius: 8))
			.scaleEffect(configuration.isPressed ? 0.95 : 1)
	}
}

struct StreakSettingsView_Previews: PreviewProvider {
	static var previews: some View {
		StreakSettingsView()
	}
}
