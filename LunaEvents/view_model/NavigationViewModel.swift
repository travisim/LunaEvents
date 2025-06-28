//
//  NavigationViewModel.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation
import SwiftUI
import Combine

enum AuthRoute:String,Hashable{
    case Login
    case Signup
    case Home
}

class NavigationViewModel:ObservableObject{
    
    @Published var authPath = NavigationPath()
    
    
    func navigate(authRoute:AuthRoute)  {
        authPath.append(authRoute)
    }
    
    func popToRoot(){
        authPath.removeLast(authPath.count)
    }
    
    func pop()  {
        authPath.removeLast()
    }
    
}
