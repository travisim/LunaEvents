//
//  LoginView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var navigationVM : NavigationViewModel
    
    var body: some View {
        
        NavigationStack(path: $navigationVM.authPath) {
            
            VStack(spacing:28) {
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(.pink)
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,height: 100)
                
                
                
                TextField("Enter email", text: $authViewModel.email)
                    .keyboardType(.emailAddress  )
                SecureField("Enter password", text: $authViewModel.password)
                
                Button(action: {
                    Task {
                        await authViewModel.signIn(email: authViewModel.email, password: authViewModel.password)
                        
                        
                    }
                }, label: {
                    if(authViewModel.isLoading){
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    else{
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                    
                })
                .padding(.horizontal,8)
                .buttonStyle(.borderedProminent)
                .disabled(!authViewModel.validEmail())
                .disabled(!authViewModel.validPassword())
                
                Text(authViewModel.errorMessage)
                    .foregroundStyle(.red)
                
                Spacer()
                NavigationLink("Sign Up", destination: SignupView())

               
                
                
            }
            .textFieldStyle(.roundedBorder)
            .padding()
            .navigationBarBackButtonHidden(true)
            
        }
        
        
    }
}

#Preview {
    NavigationStack{
        LoginView()
            .environmentObject(AuthViewModel())
            .environmentObject(NavigationViewModel())
        
        
    }
}
