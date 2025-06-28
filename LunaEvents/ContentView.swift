//
//  ContentView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI
import Supabase

struct ContentView: View {
    
    @EnvironmentObject private var authViewModel : AuthViewModel
    @EnvironmentObject private var navigationViewModel : NavigationViewModel
    
    var body: some View{
        Group{
            switch (authViewModel.authState) {
            case .Initial:
                Text("Loading")
            case .Signin:
                MainView()
                    .environmentObject(authViewModel)
                    .environmentObject(navigationViewModel)
            case .Signout:
                LoginView()
                    .environmentObject(authViewModel)
                    .environmentObject(navigationViewModel)
            }
        }
        .task {
            await authViewModel.isUserSignIn()
            
        }

    }

}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(NavigationViewModel())
}
