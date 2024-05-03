import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel = UserStateViewModel()

    var body: some View {
        VStack {
            userProfileImage
            userDetails
            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.fetchUserProfile()
            }
        }
    }

    @ViewBuilder
    private var userProfileImage: some View {
        Group {
            if let image = viewModel.userProfileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(), value: viewModel.userProfileImage)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var userDetails: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(viewModel.userName ?? "Fetching user details...")
                .font(.title2)
                .fontWeight(.semibold)

            if let email = viewModel.userEmail {
                Text(email)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            if let sex = viewModel.userSex {
                Text(sex)
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            if let age = viewModel.userAge {
                Text("Age: \(age)")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
    }

    private var refreshProfileButton: some View {
        Button(action: {
            Task {
                await viewModel.fetchUserProfile()
            }
        }) {
            Label("Refresh Profile", systemImage: "arrow.clockwise")
                .labelStyle(.titleAndIcon)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 5)
                .animation(.easeInOut, value: viewModel.isBusy)
        }
    }
}
