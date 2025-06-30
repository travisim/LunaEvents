//
//  SupabaseManager.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://iqfcfhftrwdgipjdlssv.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmNmaGZ0cndkZ2lwamRsc3N2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEwMDcxMDYsImV4cCI6MjA2NjU4MzEwNn0.lgvBf8CW5pv9dicFAfh00pfFr-C9uk6GtOKtvnR9Yfk"
        )
    }
    
    func updateLocation(latitude: Double, longitude: Double) async {
        do {
            let session = try await client.auth.session
            let userId = session.user.id
            
            let locationData: [String: Double] = [
                "last_latitude": latitude,
                "last_longitude": longitude
            ]
            
            try await client.database
                .from("profiles")
                .update(values: locationData)
                .eq(column: "id", value: userId)
                .execute()
            
            print("Location updated successfully")
        } catch {
            print("Error updating location: \(error)")
        }
    }
    
    func getFriends() async throws -> [Profile] {
        let response: [Profile] = try await client.functions
            .invoke(functionName: "get-friends")
        return response
    }
    
    func getRecommendedEvents() async throws -> [LumaEvent] {
        let session = try await client.auth.session
        let userId = session.user.id
        
        let body: [String: String] = ["user_id": userId.uuidString]
        let options = FunctionInvokeOptions(body: body)
        
        let response: [LumaEvent] = try await client.functions
            .invoke(functionName: "get-recommended-events", invokeOptions: options)
        return response
    }
    
    func fetchLumaEvents() async throws -> [LumaEvent] {
        do {
            let response: [LumaEvent] = try await client.database
                .from("luma_events")
                .select()
                .order(column: "id")
                .execute()
                .value
            return response
        } catch {
            print("Error fetching luma events: \(error)")
            throw error
        }
    }
} 
