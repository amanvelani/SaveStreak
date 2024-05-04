//
//  AboutUsView.swift
//  SaveStreak
//
//  Created by Aman Velani on 5/3/24.
//


import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

struct DeveloperView: View {
    var name: String
    var imageName: String
    var action: () -> Void

    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                
                Button(name, action: action)
                    .font(.headline)
        }
    }
}


struct ParentView: View {

    var body: some View {
        VStack {
            AboutUsView()
        }.background(BackgroundGradient())
    }
}


struct AboutUsView: View {
    @State private var showingAmanSafari = false
    @State private var showingChinmaySafari = false
    @State private var showingProjectSafari = false
    let amanGithubURL = URL(string: "https://github.com/amanvelani")
    let chinmayGithubURL = URL(string: "https://github.com/chinmayyadav")
    let projectURL = URL(string: "https://github.com/amanvelani/SaveStreak")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image("homeScreen")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(12)

                Text("About SaveStreak")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.green)
                    .shadow(color: .gray, radius: 1, x: 0, y: 2)
                    .padding(.vertical, 10)

                Text("Introduction to SaveStreak: A comprehensive app designed to transform your financial habits through detailed tracking, insights, and personalized goals. Our vision is to make financial management accessible, insightful, and engaging for everyone.")
                    .font(.body)
                    .padding()
                
                

                VStack(alignment: .leading) {
                    Text("Meet the Developers")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(){
                        DeveloperView(name: "Aman Velani", imageName: "amanPhoto"){
                            self.showingAmanSafari = true
                        }
                        Spacer()
                        DeveloperView(name: "Chinmay Yadav", imageName: "chinmayPhoto"){
                            self.showingChinmaySafari = true
                        }
                        
                        
                    }.padding()
                    HStack(){
                        Spacer()
                        Text("Follow the Project")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.blue)
                            .onTapGesture {
                                self.showingProjectSafari = true
                            }
                        Spacer()
                    }
                    
                }
                .padding()
            }
            .padding()
        }
        .sheet(isPresented: $showingAmanSafari) {
            if let url = amanGithubURL {
                SafariView(url: url)
            }
        }
        .sheet(isPresented: $showingChinmaySafari) {
            if let url = chinmayGithubURL {
                SafariView(url: url)
            }
        }
        .sheet(isPresented: $showingProjectSafari) {
            if let url = projectURL {
                SafariView(url: url)
            }
        }
        .navigationBarTitle("About Us", displayMode: .inline)
    }
}
