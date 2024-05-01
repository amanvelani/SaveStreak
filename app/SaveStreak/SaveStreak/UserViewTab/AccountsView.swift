//
//  AccountsView.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 4/28/24.
//


import SwiftUI
import LinkKit
import FirebaseAuth

struct AccountsView: View {
	@State private var accounts: [Account] = []
	@State private var isPresentingLink = false
	@State private var linkToken: String?
	@EnvironmentObject var apiConfig: ApiConfig

	
	var body: some View {
		NavigationView {
			List {
				ForEach(accounts, id: \.id) { account in
					Text(account.name)
				}
				Button(action: {
					if let _ = linkToken {
						isPresentingLink = true
					} else {
						print("Link token is not yet available.")
					}					}, label:  {
						Text("Open Plaid Link")
					})
				.disabled(linkToken == nil)
			}
			.navigationTitle("Accounts")
			.sheet(
				isPresented: $isPresentingLink,
				onDismiss: {
					isPresentingLink = false
				},
				content: {
					if let handler = createHandler() {
						LinkController(handler: handler)
					} else {
						Text("Unable to create Plaid Link handler.")
					}
				}
			)
			.onAppear {
				Task {
					await fetchLinkToken()
					await fetchAccounts()
				}
				
			}
		}
	}
	
	private func fetchAccounts() async{
		accounts = [
			Account(id: "1", name: "Checking"),
			Account(id: "2", name: "Savings")
		]
	}
	
	private func fetchLinkToken() async {
		do {
			let url = URL(string: "\(apiConfig.baseUrl)/plaid/create-link-token")!
			let (data, _) = try await URLSession.shared.data(from: url)
			let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
			linkToken = tokenResponse.link_token
			print("linkToken: \(linkToken ?? "nil")")
		} catch {
			print("An error occurred: \(error)")
			linkToken = nil
		}
	}
	
	func saveUserPublicToken(token: String) async  {
		do {
			let url = URL(string: "\(apiConfig.baseUrl)/plaid/set-access-token")!
			guard let userId = Auth.auth().currentUser?.uid else {
				print("No user is logged in.")
				return
			}
			var request = URLRequest(url: url)
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			
			let requestBody = [
				"public_token": token,
				"user_id": userId
			]
			request.httpBody = try JSONEncoder().encode(requestBody)
			
			let (data, _) = try await URLSession.shared.data(for: request)
			let tokenResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
			let status = tokenResponse.status
			print("saveUserPublicToken Status: \(status )")
			print("saveUserPublicToken Error: \(tokenResponse.error ?? "nil")")
		} catch {
			print("An error occurred: \(error)")
		}
	}
	
	
	func createHandler() -> Handler? {
		guard let token = linkToken else {
			print("No link token available.")
			return nil
		}
		var configuration = LinkTokenConfiguration(token: token) { success in
			print("public-token: \(success.publicToken) metadata: \(success.metadata)")
			let publicToken = success.publicToken
			Task {
				await saveUserPublicToken(token: publicToken)
			}
			
			isPresentingLink = false
		}
		configuration.onExit = { exit in
			
			if let error = exit.error {
				print("exit with \(error)\n\(exit.metadata)")
			} else {
				print("exit without error \(exit.metadata)")
			}
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
