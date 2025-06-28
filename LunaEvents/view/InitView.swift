//
//  InitView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI

struct InitView: View {
    @StateObject var authViewModel: AuthViewModel = AuthViewModel()
    @StateObject var navigationViewModel: NavigationViewModel = NavigationViewModel()
    @StateObject var friendsViewModel: FriendsViewModel = FriendsViewModel()
    @StateObject var eventsViewModel: EventsViewModel = EventsViewModel()
    @StateObject var permissionsManager: PermissionsManager = PermissionsManager.shared
    
    var body: some View {
        ContentView()
    }
    
    private func ContentView() -> some View {
        VStack{
            Text("Loading")
        }
        .task {
          await authViewModel.isUserSignIn()
        }
        .onAppear {
            permissionsManager.checkAllPermissions()
        }
    }
}

#Preview {
    InitView()
        .environmentObject(NavigationViewModel())
        .environmentObject(AuthViewModel())
}
