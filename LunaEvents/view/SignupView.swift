//
//  SignupView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI

struct SignupView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var navigationVM : NavigationViewModel
    
    var body: some View {
        VStack(spacing:28) {
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 8)
                .fill(.pink)
                .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/,height: 100)
                
            
            TextField("Enter email", text: $authViewModel.email)
            SecureField("Enter password", text: $authViewModel.password)
            
            Text("Password must:\n• Be at least 8 characters\n• Include at least one uppercase letter\n• Include at least one lowercase letter\n• Include at least one digit\n• Include at least one . (period) character")
                .font(.footnote)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
            
            Button(action: {
                Task {
                    await authViewModel.signup(email: authViewModel.email, password: authViewModel.password)
                    
                }
            }, label: {
                if(authViewModel.isLoading){
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                else{
                    Text("Sign Up")
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
            NavigationLink("Already have a account", destination: LoginView())
            
           
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack{
        SignupView()
            .environmentObject(AuthViewModel())

    }
}
