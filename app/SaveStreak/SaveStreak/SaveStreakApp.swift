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
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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


class AppDelegate: NSObject, UIApplicationDelegate {
	
	static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely
	
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return AppDelegate.orientationLock
	}
}
