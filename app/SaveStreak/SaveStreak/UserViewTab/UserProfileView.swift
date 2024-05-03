import SwiftUI

struct UserProfileView: View {
    @StateObject var viewModel = UserStateViewModel()

    var body: some View {
        VStack {
            Group {
                if let image = viewModel.userProfileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }
            }

            Text(viewModel.userName ?? "Fetching user details...")
                .font(.title)
                .fontWeight(.medium)
            
            if viewModel.isBusy {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            }

            Button(action: refreshProfile) {
                Text("Refresh Profile")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: refreshProfile)
    }
    
    private func refreshProfile() {
        Task {
            await viewModel.fetchUserProfile()
        }
    }
}
