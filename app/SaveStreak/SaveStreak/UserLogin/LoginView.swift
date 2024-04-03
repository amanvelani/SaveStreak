import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: UserStateViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingRegisterView = false // For navigation

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                Button(action: {
                    Task {
                        await vm.signIn(email: email, password: password)
                    }
                }) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // Register Button
                Button("Register") {
                    isShowingRegisterView = true
                }
                .padding()
                .foregroundColor(.blue)

                if vm.isBusy {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
            // Navigation to RegisterView
            .background(
                NavigationLink(destination: RegisterView(), isActive: $isShowingRegisterView) { EmptyView() }
            )
        }
    }
}

// Define your RegisterView
struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var location = ""
    @State private var selectedOccupation = "Student" // Default selection
    let occupations = ["Student", "Professional", "Self-Employed", "Retired", "Other"]


    var body: some View {
        VStack(spacing: 20) {
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            TextField("Name", text: $name)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)


            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            TextField("Location", text: $location)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)

            
            HStack {
                                Picker("Occupation", selection: $selectedOccupation) {
                                    ForEach(occupations, id: \.self) { occupation in
                                        Text(occupation).tag(occupation)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity) // Make the picker expand
                                .padding(8) // Inner padding for the picker content
                            }
                            .background(Color(.systemGray6)) // Background for the encapsulating HStack
                            .cornerRadius(8) // Corner radius for the HStack
                            .padding(.horizontal) 


            // Implement your registration logic here
            Button("Create Account") {
                // Registration action
            }
            .foregroundColor(.white)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .padding()
    }
}

// Remember to set a preview for your new RegisterView if needed
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
