	//
	//  UserView.swift
	//  SaveStreak
	//
	//  Created by Chinmay Yadav on 3/11/24.
	//

import SwiftUI
import LinkKit
import FirebaseAuth


struct UserView: View {
	@ObservedObject var loginViewModel: UserStateViewModel
	@State private var isLoggedOut = false
	@State private var isPresentingLink = false
	@State var linkToken: String? = nil
	@EnvironmentObject var apiConfig: ApiConfig

	
	var body: some View {
		NavigationView {
			List {
				Section {
					NavigationLink(destination: UserProfileView() ) {
						HStack {
							Image(systemName: "gear")
								.foregroundColor(.gray)
							Text("General")
						}
					}
					NavigationLink(destination: AccountsView()) {
						HStack {
							Image(systemName: "person.crop.circle")
								.foregroundColor(.gray)
							Text("Accounts")
						}
					}
				}
                
				
                Section {
                    NavigationLink(destination: StreakSettingsView()) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.gray)
                            Text("Streak Settings")
                        }
                    }
                    NavigationLink(destination: ParentView()) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.gray)
                            Text("About Us")
                        }
                    }
                }
				
					// Log Out Button Section
				Section {
					Button {
						Task{
							await loginViewModel.signOut()
						}
					} label: {
						Text("Logout")
					}
				}
			}
			.navigationTitle("Settings")
        }
		.onAppear() {
            OrientationManager.shared.updateOrientation(.all)
		}
		
	}
	
	func fetchLinkToken() async  {
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
	
	struct TokenResponse: Decodable {
		var link_token: String
		var expiration: String
		var request_id: String
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
}
