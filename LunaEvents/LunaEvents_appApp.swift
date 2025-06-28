//
//  LunaEvents_appApp.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI

@main
struct LunaEvents_appApp: App {
    
    @StateObject var authViewModel: AuthViewModel = AuthViewModel()
    @StateObject var navigationViewModel: NavigationViewModel = NavigationViewModel()
    @StateObject var friendsViewModel: FriendsViewModel = FriendsViewModel()
    @StateObject var eventsViewModel: EventsViewModel = EventsViewModel()
    @StateObject var permissionsManager: PermissionsManager = PermissionsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(navigationViewModel)
                .environmentObject(friendsViewModel)
                .environmentObject(eventsViewModel)
                .onAppear {
                    permissionsManager.checkAllPermissions()
                }
        }
    }
}
