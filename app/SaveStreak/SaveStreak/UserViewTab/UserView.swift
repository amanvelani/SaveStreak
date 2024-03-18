//
//  UserView.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 3/11/24.
//

import SwiftUI

struct UserView: View {
    @ObservedObject var loginViewModel: UserStateViewModel
    @State private var isLoggedOut = false
    
    
    var body: some View {
        VStack {
            Text("User")
            Button {
                Task{
                    await loginViewModel.signOut()
                }
            } label: {
                Text("Logout")
            }
            .foregroundColor(.white)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(8)
            .padding(.horizontal)
            
        }
    }
}

//#Preview {
//    UserView()
//}
