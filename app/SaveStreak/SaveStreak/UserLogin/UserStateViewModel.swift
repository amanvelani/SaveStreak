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
    case signInError, signOutError, registerError, backendError, imageConversionError, alreadyUploadingError, noUserLoggedIn
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
    @Published var userProfileImage: UIImage? = UIImage(systemName: "person.crop.circle.badge.exclamationmark")
    @Published var isFirstTimeUser = false
    @Published var doesNotHaveAccount = false
    @Published var isUploadingImage = false
    @Published var userName: String?
    @Published var userEmail: String?
    @Published var userSex: String?
    @Published var userAge: Int?


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
            guard !isUploadingImage else {
                print("Upload is already in progress.")
                throw UserStateError.alreadyUploadingError
            }

            isUploadingImage = true
            defer { isUploadingImage = false }

            guard let imageData = image.jpegData(compressionQuality: 0.4) else {
                throw UserStateError.imageConversionError
            }

            let storage = Storage.storage()
            let storageRef = storage.reference()
            let fileRef = storageRef.child("profile_images/\(userId).jpg")

            do {
                // Upload image data to Firebase Storage
                _ = try await fileRef.putData(imageData, metadata: nil)
                print("Image uploaded successfully")
            } catch {
                print("Error during upload: \(error)")
                throw UserStateError.backendError
            }
        }
    
    func fetchUserProfile() async {
        isBusy = true
        defer { isBusy = false }

        do {
            guard let userId = Auth.auth().currentUser?.uid else {
                throw UserStateError.noUserLoggedIn
            }
            
            let image = try await getUserProfileImage(userId: userId)
            userProfileImage = image
            
            let userDataResult = await getUserDataFromMongoDB(userId: userId)
            switch userDataResult {
            case .success(let userData):
                userName = (userData.name)
                userAge = userData.age
                userEmail = userData.email
                userSex = userData.sex
            case .failure:
                userName = "Error fetching data"
            }
        } catch {
            print("Error: \(error)")
            if let userStateError = error as? UserStateError {
                userName = "Error: \(userStateError)"
            } else {
                userName = "Error fetching profile"
            }
        }
    }
    private func getUserProfileImage(userId: String) async throws -> UIImage {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let fileRef = storageRef.child("profile_images/\(userId).jpg")
        
        let data = try await fileRef.getDataAsync(maxSize: 10 * 1024 * 1024) // 10MB max size
        if let image = UIImage(data: data) {
            return image
        } else {
            throw UserStateError.imageConversionError
        }
    }



        private func getUserDataFromMongoDB(userId: String) async -> Result<UserDataResponse, Error> {
            guard let url = URL(string: "\(apiConfig.baseUrl)/user/get-user-data") else {
                return .failure(UserStateError.backendError)
            }

            let payload = ["user_id": userId]
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONEncoder().encode(payload)
                let (data, _) = try await URLSession.shared.data(for: request)
                let userData = try JSONDecoder().decode(UserDataResponse.self, from: data)
                return .success(userData)
            } catch {
                return .failure(error)
            }
        }
}

struct RegistrationResponse: Codable {
    let success: Bool
}

struct UserDataResponse: Codable{
    let email: String
    let name: String
    let age: Int
    let sex: String
}

extension StorageReference {
    func getDataAsync(maxSize size: Int64) async throws -> Data {
        // Using withCheckedThrowingContinuation to specify that this function can throw an error.
        try await withCheckedThrowingContinuation { continuation in
            self.getData(maxSize: size) { data, error in
                if let error = error {
                    continuation.resume(throwing: error) // This error is of type Error, which is what is expected.
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: UserStateError.imageConversionError) // Make sure UserStateError conforms to Error.
                }
            }
        }
    }
}
