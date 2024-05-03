//
//  RegisterView.swift
//  SaveStreak
//
//  Created by Aman Velani on 5/2/24.
//
import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var vm: UserStateViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var age = ""
    @State private var sex = "Not Specified"
    @State private var profileImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isRegistering = false
    @State private var errorMessage = ""

    let sexOptions = ["Male", "Female", "Not Specified"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                profileImageView
                inputFields
                sexPicker
                registerButton
                signInButton
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $profileImage)
//                Text("sdfsdf")
            }
        }
    }

    private var profileImageView: some View {
        Button(action: {
            isImagePickerPresented = true
        }) {
            if let image = profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }

    private var inputFields: some View {
        Group {
            TextField("Name", text: $name)
                .textInputAutocapitalization(.words)
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
            SecureField("Password", text: $password)
            SecureField("Confirm Password", text: $confirmPassword)
            TextField("Age", text: $age)
                .keyboardType(.numberPad)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private var sexPicker: some View {
        Picker("Sex", selection: $sex) {
            ForEach(sexOptions, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }

    private var registerButton: some View {
        Button(action: registerUser) {
            if isRegistering {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Create Account")
                    .foregroundColor(.white)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .cornerRadius(8)
        .padding(.horizontal)
        .disabled(isRegistering || !passwordsMatch)
        .padding(.top, 10)
    }
    
    private var signInButton: some View {
        Button(action: {
            vm.isFirstTimeUser = false
        }) {
            Text("Sign In")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .cornerRadius(8)
        .padding(.horizontal)
        .disabled(isRegistering || !passwordsMatch)
        .padding(.top, 10)
    }
    
    
    

    private var passwordsMatch: Bool {
        password == confirmPassword && !password.isEmpty
    }

    func registerUser() {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty, let userAge = Int(age), !sex.isEmpty else {
            errorMessage = "Please fill in all fields correctly."
            return
        }
        isRegistering = true
        errorMessage = ""

        Task {
            let result = await vm.register(email: email, password: password, name: name, age: userAge, sex: sex, profileImage: profileImage)
            if case .failure(let error) = result {
                errorMessage = "Registration failed: \(error.localizedDescription)"
            }
            vm.isLoggedIn = true
            vm.isFirstTimeUser = false
            isRegistering = false
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
