//
//  ConnectionRequest.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation

struct ConnectionRequest: Codable, Identifiable {
    let id: UUID
    let requester_name: String
    let addressee_name: String
    let requester_id: UUID
    let addressee_id: UUID
} 
