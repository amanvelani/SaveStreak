	//
	//  SaveStreakApp.swift
	//  SaveStreak
	//
	//  Created by Chinmay Yadav on 3/4/24.
	//

import SwiftUI
import FirebaseCore
import Firebase

@main
struct SaveStreakApp: App {
	@StateObject var userStateViewModel = UserStateViewModel()
	let api_config = ApiConfig()
	
	init() {
		let providerFactory = AppCheckDebugProviderFactory()
		AppCheck.setAppCheckProviderFactory(providerFactory)
		
		FirebaseApp.configure()
		FirebaseConfiguration.shared.setLoggerLevel(.min)
		
	}
	
	var body: some Scene {
		WindowGroup {
			NavigationView{
				ApplicationSwitcher()
			}
			.navigationViewStyle(.stack)
			.environmentObject(userStateViewModel)
			.environmentObject(api_config)
		}
	}
}

struct ApplicationSwitcher: View {
	
	@EnvironmentObject var vm: UserStateViewModel
	
	var body: some View {
		if (vm.isLoggedIn || UserDefaults.standard.bool(forKey: "isLoggedIn")) {
			HomeScreen()
        } else if(vm.isFirstTimeUser){
            RegisterView()
        }
        else{
			LoginView()
		}
		
	}
}

