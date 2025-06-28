//
//  AddConnectionView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI

struct AddConnectionView: View {
    @State private var username: String = ""
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var friendsViewModel = FriendsViewModel()

    var body: some View {
        VStack {
            TextField("Enter username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Send Request") {
                friendsViewModel.sendRequest(to: username)
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Add Connection")
    }
}

struct AddConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        AddConnectionView()
    }
} 