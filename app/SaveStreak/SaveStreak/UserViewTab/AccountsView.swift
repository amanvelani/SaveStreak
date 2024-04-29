//
//  AccountsView.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 4/28/24.
//


import SwiftUI
import LinkKit

struct AccountsView: View {
	@State private var accounts: [Account] = []
	@State private var isPresentingLink = false
	@State private var linkToken: String?
	
	var body: some View {
		NavigationView {
			List {
				ForEach(accounts, id: \.id) { account in
					Text(account.name)
				}
				Button("Add Account") {
					Task {
						await fetchLinkToken()
					}
				}
				.disabled(linkToken == nil)
			}
			.navigationTitle("Accounts")
			.sheet(isPresented: $isPresentingLink, onDismiss: { isPresentingLink = false }) {
				if let handler = createHandler() {
					LinkController(handler: handler)
				} else {
					Text("Unable to create Plaid Link handler.")
				}
			}
			.onAppear {
				fetchAccounts()
			}
		}
	}
	
	private func fetchAccounts() {
			// Mockup of fetching accounts
			// Replace this with your actual API call to fetch accounts
		accounts = [
			Account(id: "1", name: "Checking"),
			Account(id: "2", name: "Savings")
		]
	}
	
	private func fetchLinkToken() async {
		do {
			let url = URL(string: "https://4098-128-230-193-37.ngrok-free.app/plaid/create-link-token")!
			let (data, _) = try await URLSession.shared.data(from: url)
			let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
			linkToken = tokenResponse.link_token
			isPresentingLink = true
			print("Successfully fetched link token: \(linkToken ?? "nil")")
		} catch {
			print("Failed to fetch link token: \(error)")
			linkToken = nil
		}
	}
	
	func createHandler() -> Handler? {
		guard let token = linkToken else {
			print("No link token available when creating handler.")
			return nil
		}
		
		var configuration = LinkTokenConfiguration(token: token) { success in
			print("public-token: \(success.publicToken) metadata: \(success.metadata)")
			isPresentingLink = false
		}
		configuration.onExit = { exit in
			print("Plaid link exited: \(exit.metadata)")
			isPresentingLink = false
		}
		configuration.onEvent = { event in
			print("Link Event: \(event)")
		}
		
		switch Plaid.create(configuration) {
		case .success(let handler):
			return handler
		case .failure(let error):
			print("Failed to create Plaid handler: \(error.localizedDescription)")
			return nil
		}
	}
	
	struct Account: Identifiable {
		var id: String
		var name: String
	}
	
	struct TokenResponse: Decodable {
		var link_token: String
		var expiration: String
		var request_id: String
	}
}


#Preview {
    AccountsView()
}
