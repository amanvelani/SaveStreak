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
    @EnvironmentObject var vm: UserStateViewModel
	@State private var accounts: [Account] = []
	@State private var isPresentingLink = false
	@State private var linkToken: String?
	@EnvironmentObject var apiConfig: ApiConfig
    @State private var isLoading = false


	
    var body: some View {
            NavigationView {
                List {
                    if isLoading {
                        ProgressView()
                    }
                    else if accounts.isEmpty {
                        VStack {
                            Spacer()
                            Text("Click on the + button to add an account")
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }
                    }
                    else{
                        ForEach(accounts, id: \.bank_name) { account in
                            AccountRow(account: account)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                }
                .background(BackgroundGradient())
                .listStyle(PlainListStyle())
                .navigationTitle("Accounts")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        addButton
                        refreshButton
                    }
                }
                .sheet(isPresented: $isPresentingLink, onDismiss: {
                    isPresentingLink = false
                }) {
                    if let handler = createHandler() {
                        LinkController(handler: handler)
                    } else {
                        Text("Unable to create Plaid Link handler.")
                    }
                }
                .onAppear {
                    Task {
                        refreshAccounts()
                    }
                }
                    
            }
        }
    
        
    private var refreshButton: some View {
        Button(action: {
            Task {
                await fetchAccounts()
            }
        }) {
            Image(systemName: "arrow.clockwise")
        }
    }
        
    private var addButton: some View {
        Button(action: {
            isPresentingLink = true
        }) {
            Image(systemName: "plus")
        }
    }
    private func refreshAccounts() {
        Task {
            isLoading = true
            defer { isLoading = false }
            await fetchLinkToken()
            await fetchAccounts()
        }
    }
	
    private func fetchAccounts() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }

        do {

            let url = URL(string: "\(apiConfig.baseUrl)/user/get-user-accounts")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let requestBody = ["user_id": userId]
            request.httpBody = try JSONEncoder().encode(requestBody)
            
            // Correctly use URLSession to handle the POST request
            let (data, _) = try await URLSession.shared.data(for: request)
            let accountResponse = try JSONDecoder().decode(AccountsResponse.self, from: data)
            
            // Process the fetched account data
            for account in accountResponse.accounts {
                print("Bank: \(account.bank_name), Type: \(account.account_type), Balance: \(account.account_balance)")
                self.accounts = accountResponse.accounts
                
            }
            isLoading = false
            
            if !self.accounts.isEmpty{
                vm.doesNotHaveAccount = false
            }
        } catch {
            print("An error occurred: \(error)")
        }
        
    }
    
    struct Account: Codable {
        let account_balance: Double
        let account_type: String
        let bank_name: String
    }

    struct AccountsResponse: Codable {
        let accounts: [Account]
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
            Task {
//                isLoading = true
                await fetchAccounts()
//                isLoading = false
            }
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
            print("\(event.eventName)")
            let name = event.eventName.description
            if name == "HANDOFF" {
//                Task {
                    isLoading = true
//                    await fetchAccounts()
//                    isLoading = false
//                }
            }
		}
		switch Plaid.create(configuration) {
		case .success(let handler):
			return handler
		case .failure(let error):
			print("Failed to create Plaid handler: \(error.localizedDescription)")
			return nil
		}
	}
	
	struct TokenResponse: Decodable {
		var link_token: String
		var expiration: String
		var request_id: String
	}
    
    struct AccountRow: View {
        var account: Account
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(account.bank_name)
                        .font(.title2)
                        .fontWeight(.bold)
                        
                    Text(account.account_type)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    
                    Text("Balance: $\(account.account_balance, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))  // Adapts to light or dark mode
            .cornerRadius(10)
            .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 2)
            .padding([.horizontal, .top])  // Adds spacing between account rows
        }
    }

    struct AccountsView_Previews: PreviewProvider {
        static var previews: some View {
            AccountsView().environmentObject(ApiConfig())
        }
    }
}
//
//
//#Preview {
//    AccountsView()
//}
