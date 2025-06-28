//
//  MainView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var friendsViewModel = FriendsViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .environmentObject(friendsViewModel)

            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
                .environmentObject(friendsViewModel)

            EventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
} 