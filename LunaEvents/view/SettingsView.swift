//
//  SettingsView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var isLoading = false
    @State private var showSuccessMessage = false
    
    let eventTypes = ["Demo Days", "Networking", "Fireside Chats", "Founders Runs"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferred Event Types")) {
                    ForEach(eventTypes, id: \.self) { eventType in
                        Button(action: {
                            toggleEventType(eventType)
                        }) {
                            HStack {
                                Text(eventType)
                                    .foregroundColor(.primary)
                                Spacer()
                                if profileViewModel.preferredEventTypes.contains(eventType) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Section {
                    Button(action: {
                        savePreferences()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text("Save Preferences")
                        }
                    }
                    .disabled(isLoading)
                }
                
                if showSuccessMessage {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Preferences saved successfully!")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                profileViewModel.fetchProfile()
            }
        }
    }
    
    private func toggleEventType(_ eventType: String) {
        if let index = profileViewModel.preferredEventTypes.firstIndex(of: eventType) {
            profileViewModel.preferredEventTypes.remove(at: index)
        } else {
            profileViewModel.preferredEventTypes.append(eventType)
        }
    }
    
    private func savePreferences() {
        isLoading = true
        showSuccessMessage = false
        
        Task {
            await profileViewModel.updatePreferredEventTypes(newTypes: profileViewModel.preferredEventTypes)
            
            await MainActor.run {
                isLoading = false
                showSuccessMessage = true
                
                // Hide success message after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showSuccessMessage = false
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 