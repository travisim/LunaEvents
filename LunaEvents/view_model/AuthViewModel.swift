//
//  AuthViewModel.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation
import Combine
import Supabase


enum AuthState:Hashable{
    case Initial
    case Signin
    case Signout
}

@MainActor
class AuthViewModel: ObservableObject{
    
    @Published var email:String = ""
    @Published var password:String = ""
    @Published var errorMessage:String = ""
    var cancellable=Set<AnyCancellable>()
    @Published var authState:AuthState = AuthState.Initial
    @Published var currentUser:User?
    @Published var userProfile:Profile?
    private var supabaseAuth:SupabaseAuth = SupabaseAuth()
    @Published var isLoading  = false
    private let permissionsManager = PermissionsManager.shared
    
    private let supabase = SupabaseManager.shared.client
    
    init(){
        Task{
            await isUserSignIn()
        }
    }
    
    @MainActor
    func isUserSignIn() async  {
        do{
            try await supabaseAuth.LoginUser()
            authState = AuthState.Signin
            permissionsManager.checkAllPermissions()
            
        }catch _{
            authState = AuthState.Signout
        }
        
        
    }
    
    
    @MainActor
    func signup(email:String,password:String) async  {
        do{
            isLoading = true
            try await supabaseAuth.SignUp(email: email, password: password)
            authState = AuthState.Signin
            isLoading = false
            
        }
        catch let error{
            errorMessage = error.localizedDescription
            isLoading = false
        }
        
        
        
    }
    
    @MainActor
    func signIn(email:String,password:String) async {
        do{
            isLoading = true
            try await supabaseAuth.SignIn(email: email, password: password)

            
            authState = AuthState.Signin
            isLoading = false
        }
        catch let error{
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    
    
    func validEmail() -> Bool {
        
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let isEmailValid = self.email.range(of: emailRegex, options: .regularExpression) != nil
        
        
        return isEmailValid
    }
    
    func validPassword() -> Bool {
        
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*\\.).{8,}$"
        let isPasswordValid = self.password.range(of: passwordRegex, options: .regularExpression) != nil
        
        return isPasswordValid
    }
    
    @MainActor
    func signoutUser() async{
        do{
            try await supabaseAuth.signOut()
            authState = AuthState.Signout
        }catch let error{
            errorMessage = error.localizedDescription
        }
        
    }
    
    
}
