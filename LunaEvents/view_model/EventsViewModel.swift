//
//  EventsViewModel.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation
import Combine
import Supabase

@MainActor
class EventsViewModel: ObservableObject {
    @Published var events: [LumaEvent] = []
    @Published var recommendedEvents: [LumaEvent] = []
    @Published var errorMessage: String?
    
    func fetchEvents() {
        Task {
            do {
                let fetchedEvents = try await SupabaseManager.shared.fetchLumaEvents()
                self.events = fetchedEvents
                self.errorMessage = nil
            } catch {
                self.errorMessage = error.localizedDescription
                print("Error fetching events: \(error)")
            }
        }
    }
    
    func fetchRecommendedEvents() {
        Task {
            do {
                let fetchedRecommendedEvents = try await SupabaseManager.shared.getRecommendedEvents()
                self.recommendedEvents = fetchedRecommendedEvents
                self.errorMessage = nil
            } catch {
                print("Error fetching recommended events: \(error)")
                // Don't set error message for recommended events failure
                // as it's not critical and user might not have preferences set
            }
        }
    }
} 