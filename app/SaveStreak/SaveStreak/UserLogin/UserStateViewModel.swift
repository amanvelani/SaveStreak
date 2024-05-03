//
//  UserStateViewModel.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 3/11/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage



enum UserStateError: Error{
    case signInError, signOutError, registerError, backendError, imageConversionError, alreadyUploadingError
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
    @Published var isFirstTimeUser = false
    @Published var isUploadingImage = false

    let apiConfig = ApiConfig()

    
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
    
    func register(email: String, password: String, name: String, age: Int, sex: String, profileImage: UIImage?) async -> Result<Bool, UserStateError> {
            isBusy = true
            defer { isBusy = false }
            
            do {
                // Create user in Firebase Auth
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                let userID = authResult.user.uid

                // Attempt to upload profile image
                let imageToUpload = profileImage ?? UIImage(named: "defaultImage")!
                try await uploadProfileImage(image: imageToUpload, userId: userID)
                let serverResponse = await registerUserInMongoDB(userId: userID, email: email, name: name, age: age, sex: sex)
                return .success(true)
            } catch UserStateError.imageConversionError, UserStateError.backendError {
                return .failure(.backendError)
            } catch {
                return .failure(.registerError)
            }
        }
    
    private func registerUserInMongoDB(userId: String, email: String, name: String, age: Int, sex: String) async -> Result<Bool, UserStateError> {
            guard let url = URL(string: "\(apiConfig.baseUrl)/user/register-user") else {
                return .failure(.backendError)
            }

            let userData: [String: Any] = [
                "userId": userId,
                "email": email,
                "name": name,
                "age": age,
                "sex": sex,
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: userData)
                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode(RegistrationResponse.self, from: data)
                if response.success {
                    return .success(true)
                } else {
                    return .failure(.backendError)
                }
            } catch {
                return .failure(.backendError)
            }
        }
    
    func uploadProfileImage(image: UIImage, userId: String) async throws -> Void {
            guard let imageData = image.jpegData(compressionQuality: 0.4) else {
                throw UserStateError.imageConversionError
            }
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let fileRef = storageRef.child("profile_images/\(userId).jpg")

            do {
                // Upload image data to Firebase Storage
                _ = try await fileRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading image: \(error)")
                        return
                    }
                    print("Image uploaded successfully")
                }
                // Retrieve and return the download URL
//                let url = try await fileRef.downloadURL()
//                return url
            } catch let error{
                print(error)
                throw UserStateError.backendError
            }
        }



    
}

struct RegistrationResponse: Codable {
    let success: Bool
}
