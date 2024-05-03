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
                            }.background(Color.white)
                MapView()
                    .tabItem {
                        Image(systemName: "storefront.circle")
                        Text("Store")
                    }.background(Color.white)

                        InsightsView()
                            .tabItem {
                                Image(systemName: "chart.xyaxis.line")
                                Text("Insights")
                            }.background(Color.white)

                        UserView(loginViewModel: vm)
                            .tabItem {
                                Image(systemName: "gear")
                                Text("Settings")
                            }.background(Color.white)
                    }
            .accentColor(.blue)
            .font(.headline)
        }
    }

}

#Preview {
    HomeScreen()
}
