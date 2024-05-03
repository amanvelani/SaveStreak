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
                    vm.isFirstTimeUser = true
//                    isShowingRegisterView = true
                }
                .padding()
                .foregroundColor(.blue)

                if vm.isBusy {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
            .background(
//                NavigationLink(destination: RegisterView(), isActive: $isShowingRegisterView) { EmptyView() }
            )
        }
    }
}
