//
//  AboutUsView.swift
//  SaveStreak
//
//  Created by Aman Velani on 5/3/24.
//

//import SwiftUI
//import SafariServices
//
//struct AboutUsView: View {
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                Image("homeScreen")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .cornerRadius(12)
//
//                Text("About SaveStreak")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(Color.green)
//                    .shadow(color: .gray, radius: 1, x: 0, y: 2)
//                    .padding(.vertical, 10)
//
//                Text("Introduction to SaveStreak: A comprehensive app designed to transform your financial habits through detailed tracking, insights, and personalized goals. Our vision is to make financial management accessible, insightful, and engaging for everyone.")
//                    .font(.body)
//                    .padding()
//
//                VStack(alignment: .leading) {
//                    Text("Meet the Developers")
//                        .font(.title2)
//                        .fontWeight(.bold)
//
//                    DeveloperView(name: "Aman Velani", imageName: "amanPhoto", githubURL: "https://github.com/amanvelani")
//                    DeveloperView(name: "Chinmay Yadav", imageName: "chinmayPhoto", githubURL: "https://github.com/chinmayyadav")
//                }
//                .padding()
//            }
//            .padding()
//        }
//        .navigationBarTitle("About Us", displayMode: .inline)
//    }
//}
//
//struct DeveloperView: View {
//    var name: String
//    var imageName: String
//    var githubURL: String
//
//    @State private var showingSafari = false
//    @State private var url: URL?
//
//    var body: some View {
//        HStack {
//            Image(imageName)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 80, height: 80)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.white, lineWidth: 3))
//                
//            VStack(alignment: .leading) {
//                Text(name)
//                Button("GitHub") {
//                    if let validURL = URL(string: githubURL) {
//                        url = validURL
//                        showingSafari = true
//                    } else {
//                        print("Invalid URL: \(githubURL)")
//                    }
//                }
//                .font(.headline)
//                .sheet(isPresented: $showingSafari) {
//                    if let url = url {
//                        SafariView(url: url)
//                    } else {
//                        Text("Invalid URL").foregroundColor(.red)
//                    }
//                }
//            }
//        }
//    }
//}
//
//
//struct SafariView: UIViewControllerRepresentable {
//    let url: URL
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
//        return SFSafariViewController(url: url)
//    }
//
//    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
//    }
//}
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
    @Binding var showingSafari: Bool
    @Binding var url: URL?
    var name: String
    var imageName: String
    var githubURL: String

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                
            VStack(alignment: .leading) {
                Text(name)
                Button("GitHub") {
                    if let validURL = URL(string: githubURL) {
                        self.url = validURL
                        self.showingSafari = true
                    } else {
                        print("Invalid URL: \(githubURL)")
                    }
                }
                .font(.headline)
            }
        }
    }
}


struct ParentView: View {
    @State private var showingSafari = false
    @State private var url: URL?

    var body: some View {
        VStack {
            AboutUsView(showingSafari: $showingSafari, url: $url)
        }
    }
}


struct AboutUsView: View {
    @Binding var showingSafari: Bool
    @Binding var url: URL?

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

                    DeveloperView(showingSafari: $showingSafari, url: $url, name: "Aman Velani", imageName: "amanPhoto", githubURL: "https://github.com/amanvelani")
                    DeveloperView(showingSafari: $showingSafari, url: $url, name: "Chinmay Yadav", imageName: "chinmayPhoto", githubURL: "https://github.com/chinmayyadav")
                }
                .padding()
            }
            .padding()
        }
        .sheet(isPresented: $showingSafari) {
            if let url = url {
                SafariView(url: url)
            } else {
                Text("Invalid URL").foregroundColor(.red)
            }
        }
        .navigationBarTitle("About Us", displayMode: .inline)
    }
}
