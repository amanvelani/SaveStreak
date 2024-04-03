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
//        VStack {
//            Text("User")
//            Button {
//                Task{
//                    await loginViewModel.signOut()
//                }
//            } label: {
//                Text("Logout")
//            }
//            .foregroundColor(.white)
//            .font(.headline)
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.red)
//            .cornerRadius(8)
//            .padding(.horizontal)
//            
//        }
//    }
//}
        NavigationView {
                    List {
                        Section {
                            NavigationLink(destination: Text("General Settings")) {
                                HStack {
                                    Image(systemName: "gear")
                                        .foregroundColor(.gray)
                                    Text("General")
                                }
                            }
                            NavigationLink(destination: Text("Account Settings")) {
                                HStack {
                                    Image(systemName: "person.crop.circle")
                                        .foregroundColor(.gray)
                                    Text("Accounts")
                                }
                            }
                        }

                        Section {
                            NavigationLink(destination: Text("Notifications Settings")) {
                                HStack {
                                    Image(systemName: "bell")
                                        .foregroundColor(.gray)
                                    Text("Notifications")
                                }
                            }
                            NavigationLink(destination: Text("Help Information")) {
                                HStack {
                                    Image(systemName: "questionmark.circle")
                                        .foregroundColor(.gray)
                                    Text("Help")
                                }
                            }
                        }

                        // Log Out Button Section
                        Section {
                            Button {
                                            Task{
                                                await loginViewModel.signOut()
                                            }
                                        } label: {
                                            Text("Logout")
                                        }
                            
                        }
                    }
                    .navigationTitle("Settings")
                }
            }
        }


//#Preview {
//    UserView()
//}
