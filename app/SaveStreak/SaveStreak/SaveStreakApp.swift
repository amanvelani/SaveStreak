//
//  SaveStreakApp.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 3/4/24.
//

import SwiftUI

@main
struct SaveStreakApp: App {
    @StateObject var userStateViewModel = UserStateViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView{
                            ApplicationSwitcher()
            }
            .navigationViewStyle(.stack)
            .environmentObject(userStateViewModel)
        }
    }
}

struct ApplicationSwitcher: View {

    @EnvironmentObject var vm: UserStateViewModel

    var body: some View {
        if (vm.isLoggedIn || UserDefaults.standard.bool(forKey: "isLoggedIn")) {
            HomeScreen()
        } else {
            LoginView()
        }

    }
}

