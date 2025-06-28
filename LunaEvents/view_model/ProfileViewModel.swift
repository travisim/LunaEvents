//
//  ProfileViewModel.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation
import Supabase

private struct ProfileEmbeddingRecord: Encodable {
    let id: String
    let preferred_event_types: [String]
}

private struct ProfileEmbeddingPayload: Encodable {
    let record: ProfileEmbeddingRecord
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var preferredEventTypes: [String] = []
    
    private let supabase = SupabaseManager.shared.client
    
    func fetchProfile() {
        Task {
            do {
                let session = try await supabase.auth.session
                let userId = session.user.id
                
                let response: [Profile] = try await supabase.database
                    .from("profiles")
                    .select()
                    .eq(column: "id", value: userId.uuidString)
                    .execute()
                    .value
                
                if let profile = response.first {
                    self.profile = profile
                    self.preferredEventTypes = profile.preferred_event_types ?? []
                }
            } catch {
                print("Error fetching profile: \(error)")
            }
        }
    }
    
    func updatePreferredEventTypes(newTypes: [String]) {
        Task {
            do {
                let session = try await supabase.auth.session
                let userId = session.user.id
                
                try await supabase.database
                    .from("profiles")
                    .update(values: ["preferred_event_types": newTypes])
                    .eq(column: "id", value: userId.uuidString)
                    .execute()
                
                self.preferredEventTypes = newTypes
                
                // Trigger the generation of profile embedding
                let body = ProfileEmbeddingPayload(record: ProfileEmbeddingRecord(id: userId.uuidString, preferred_event_types: newTypes))
                let options = FunctionInvokeOptions(body: body)
                
                try await supabase.functions
                    .invoke(functionName: "generate-profile-embedding", invokeOptions: options)
                
            } catch {
                print("Error updating preferred event types: \(error)")
            }
        }
    }
} 
