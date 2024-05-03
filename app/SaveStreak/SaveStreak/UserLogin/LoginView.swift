import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: UserStateViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingRegisterView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Logo Placeholder - replace with your logo
                Image("homeScreen")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 160, height: 160) // Smaller size
                                    .clipShape(Circle())

                

                

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
                        .background(Color.green)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                Button("Register") {
                    vm.isFirstTimeUser = true
                }
                .foregroundColor(.green)
                .padding()
                
                Spacer()
                
                Text("SaveStreak")
                    .font(.largeTitle) // Using a bold and heavy system font
                    .foregroundColor(Color.green) // Text color
                    .shadow(color: .gray, radius: 1, x: 0, y: 2) // Subtle shadow for depth
                    .padding(.vertical, 10)
                
                Text("Streak to Peak: Elevate Your Habits, Elevate Your Life!")
                    .font(.footnote) // Smaller font size
                    .foregroundColor(.gray)
                    .lineLimit(1) // Ensures text stays on one line
                    .truncationMode(.tail) // Truncates with an ellipsis if text is too long
                    .padding(.horizontal, 10) // Reduced horizontal padding

                
                if vm.isBusy {
                    ProgressView()
                }
            }
            .padding()
            .background(Color.white.edgesIgnoringSafeArea(.all))
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}
