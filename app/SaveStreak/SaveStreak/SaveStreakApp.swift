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
        if(vm.isLoggedIn && vm.doesNotHaveAccount){
            AccountsView()
        }
		else if (vm.isLoggedIn || UserDefaults.standard.bool(forKey: "isLoggedIn")) {
			HomeScreen()
        }
        else if(vm.isFirstTimeUser){
            RegisterView()
        }
        else{
			LoginView()
		}
		
	}
}


class OrientationManager {
    static var shared = OrientationManager()
    private init() {}

    var orientationLock: UIInterfaceOrientationMask = .all {
        didSet {
            // Notify AppDelegate to update orientation settings
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.updateOrientation()
            }
        }
    }

    func updateOrientation(_ orientation: UIInterfaceOrientationMask) {
        self.orientationLock = orientation
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return OrientationManager.shared.orientationLock
    }

    func updateOrientation() {
        // Trigger the application to check orientation restrictions
        UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
    }
}

