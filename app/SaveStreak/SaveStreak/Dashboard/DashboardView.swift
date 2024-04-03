//
//  HomeScreen.swift
//  SaveStreak
//
//  Created by Chinmay Yadav on 3/11/24.
//

import SwiftUI

struct HomeScreen: View {
    
    @EnvironmentObject var vm: UserStateViewModel

    var body: some View {

        if(vm.isBusy){
            ProgressView()
        } else{
            TabView {
                        HomeView()
                            .tabItem {
                                Image(systemName: "house")
                                Text("Home")
                            }
                MapView()
                    .tabItem {
                        Image(systemName: "storefront.circle")
                        Text("Store")
                    }

                        InsightsView()
                            .tabItem {
                                Image(systemName: "chart.xyaxis.line")
                                Text("Insights")
                            }

                        UserView(loginViewModel: vm)
                            .tabItem {
                                Image(systemName: "gear")
                                Text("Settings")
                            }
                    }
        }
    }

}

#Preview {
    HomeScreen()
}
