//
//  Profile.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation



struct Profile: Codable, Identifiable {
    let id: UUID
    let updatedAt: Date?
    let username: String
    let fullName: String?
    let avatarUrl: String?
    let website: String?
    let lastLatitude: Double?
    let lastLongitude: Double?
    let lastLocationUpdated: String?
    let interests: String?
    let preferred_event_types: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case updatedAt = "updated_at"
        case username
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case website
        case lastLatitude = "last_latitude"
        case lastLongitude = "last_longitude"
        case lastLocationUpdated = "last_location_updated"
        case interests
        case preferred_event_types = "preferred_event_types"
    }
}
