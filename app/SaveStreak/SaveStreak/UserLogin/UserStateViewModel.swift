//
//  UserStateViewModel.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 3/11/24.
//

import Foundation
import Firebase

enum UserStateError: Error{
    case signInError, signOutError
}

struct UserLoginResponse:  Identifiable, Decodable{
    let id: String
    let category: String
    let email: String
    let password: String
}


@MainActor
class UserStateViewModel: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var isBusy = false
    
    func signIn(email: String, password: String) async -> Result<Bool, UserStateError>  {
        isBusy = true
        do{
			Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
				guard let self = self else { return }
				if let user = authResult?.user, error == nil {
					print("User logged in: \(user.email ?? "")")
					self.isBusy = false
					self.isLoggedIn = true
//					self.navigationDestination = .mainPage
					UserDefaults.standard.set(true, forKey: "isLoggedIn")
				} else if let error = error {
					print("Login error: \(error.localizedDescription)")
				}
			}
			return .success(true)
        }catch{
            isBusy = false
            return .failure(.signInError)
        }
    }
    
    func signOut() async -> Result<Bool, UserStateError>  {
        isBusy = true
        do{
            try await Task.sleep(nanoseconds: 1_000_000_000)
			try Auth.auth().signOut()
            isLoggedIn = false
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            isBusy = false
            return .success(true)
        }catch{
            isBusy = false
            return .failure(.signOutError)
        }
    }
}
