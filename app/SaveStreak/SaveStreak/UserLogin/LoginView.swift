import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: UserStateViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingRegisterView = false

    var body: some View {
		
			NavigationView {
				
					ZStack {
						Image("moneyPlant") // Replace "your_background_image" with the actual name of your image asset
							.resizable()
							.scaledToFill()
							.edgesIgnoringSafeArea(.all) 
							.overlay(Color.gray.opacity(0.1))
						

						VStack(spacing: 20) {
						Spacer()
						
							// Logo Placeholder - ensure this image is visible in both light and dark mode
						Image("homeScreen")
							.resizable()
							.scaledToFit()
							.frame(width: 160, height: 160)
							.clipShape(Circle())
							.shadow(radius: 10)  // Adding shadow for better contrast
						
						TextField("Email", text: $email)
							.keyboardType(.emailAddress)
							.disableAutocorrection(true)
							.autocapitalization(.none)
							.padding()
							.background(Color(UIColor.systemGray6)) // Slightly lighter background for contrast
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(Color.secondary, lineWidth: 0.5) // Adding a subtle border
							)
							.padding(.horizontal)
						
						SecureField("Password", text: $password)
							.padding()
							.background(Color(UIColor.systemGray6)) // Slightly lighter background for contrast
							.cornerRadius(8)
							.overlay(
								RoundedRectangle(cornerRadius: 8)
									.stroke(Color.secondary, lineWidth: 0.5) // Adding a subtle border
							)
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
							.font(.footnote)
							.foregroundColor(Color.secondary)  // Secondary color for less emphasis
							.lineLimit(1)
							.truncationMode(.tail)
							.padding(.horizontal, 10)
						
						if vm.isBusy {
							ProgressView()
						}
					}
				}
				.background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
				.navigationTitle("")
				.navigationBarHidden(true)
			}
			.edgesIgnoringSafeArea(.all)
		}
    }

