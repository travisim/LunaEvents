//
//  SupabaseAuth.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation
import Combine
import Supabase


class SupabaseAuth {
    
    let client = SupabaseManager.shared.client
    
    func LoginUser() async throws {
        do{
            let session = try await client.auth.session
            
        }catch let error{
            throw error
        }
    }
    
    func SignIn(email:String,password:String) async throws {
        do{
            try await client.auth.signIn(email: email.lowercased(), password: password)
        }catch let error{
            throw error
        }
    }
    
    
    func SignUp(email:String,password:String) async throws{
        do{
            try await client.auth.signUp(email: email.lowercased(), password: password)
        }catch let error{
            throw error
        }
    }
    
    func signOut() async throws{
        do{
            try await client.auth.signOut()
        }catch let error{
            throw error
        }
    }

    func fetchLumaEvents() async throws -> [LumaEvent] {
        do {
            let response: [LumaEvent] = try await client.database
                .from("luma_events")
                .select()
                .execute()
                .value
            return response
        } catch {
            throw error
        }
    }
}
