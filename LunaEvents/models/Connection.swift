//
//  Connection.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation

struct Connection: Codable {
    var id: UUID?
    var requester_id: UUID
    var addressee_id: UUID
    var status: String
    var requester: Profile?

    init(id: UUID? = nil, requester_id: UUID, addressee_id: UUID, status: String, requester: Profile? = nil) {
        self.id = id
        self.requester_id = requester_id
        self.addressee_id = addressee_id
        self.status = status
        self.requester = requester
    }
} 
