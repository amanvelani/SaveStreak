//
//  UserStateViewModel.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 3/11/24.
//

import Foundation

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
            let loginUrl = URL(string: "http://192.168.1.199:8080/login")!
            var request = URLRequest(url: loginUrl)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let requestBody: [String: Any] = [
                "email": email,
                "password": password
            ]
            
//            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
//            let (data, response) = try await URLSession.shared.data(for: request)
//            debugPrint((response as? HTTPURLResponse)?.statusCode)
//            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return .failure(.signInError)}
//            let decodedResponse = try JSONDecoder().decode(UserLoginResponse.self, from: data)
//            debugPrint("Async decodedResponse", decodedResponse)
            isLoggedIn = true
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            isBusy = false
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
