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
			Form {
				Picker("Category", selection: $viewModel.selectedCategory) {
					ForEach(viewModel.categories, id: \.self) {
						Text($0)
					}
				}
				.onAppear {
					viewModel.fetchCategories()
					viewModel.fetchExistingExpense()
				}
				TextField("Amount", text: $viewModel.amount)
					.keyboardType(.decimalPad)
				Button("Save") {
					viewModel.saveExpense()

				}
			}
			.navigationTitle("Add Expense")
//			.toolbar {
//				ToolbarItem(placement: .navigationBarTrailing) {
//					Button("Save") {
//						viewModel.saveExpense()
//					}
//				}
//			}
		}
	}

}

#Preview {
    StreakSettingsView()
}
