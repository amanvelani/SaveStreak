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

                        InsightsView()
                            .tabItem {
                                Image(systemName: "chart.bar")
                                Text("Insights")
                            }

                        UserView(loginViewModel: vm)
                            .tabItem {
                                Image(systemName: "person")
                                Text("User")
                            }
                    }
        }
    }

}

#Preview {
    HomeScreen()
}
