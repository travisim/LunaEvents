//
//  FriendsViewModel.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation
import Supabase
import CoreLocation

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var incomingRequests: [ConnectionRequest] = []
    @Published var friends: [Profile] = []
    @Published var meetingPoint: CLLocationCoordinate2D?
    @Published var meetingFriend: Profile?
    
    var mapAnnotations: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = friends
            .filter { $0.lastLatitude != nil && $0.lastLongitude != nil }
            .map { .friend($0) }

        if let meetingPoint = meetingPoint {
            items.append(.meetingPoint(meetingPoint))
        }

        return items
    }
    
    init() {
        fetchFriends()
    }
    
    private let supabase = SupabaseManager.shared.client

    func fetchIncomingRequests() {
        Task {
            do {
                let session = try await supabase.auth.session
                let addresseeId = session.user.id
                
                let body: [String: String] = ["addressee_id": addresseeId.uuidString]
                let options = FunctionInvokeOptions(body: body)
                let requests: [ConnectionRequest] = try await supabase.functions
                    .invoke(functionName: "get-connection-requests", invokeOptions: options)
                
                self.incomingRequests = requests
            } catch {
                print("Error fetching incoming requests: \(error)")
                if let decodingError = error as? DecodingError {
                    print("Detailed decoding error: \(decodingError)")
                }
            }
        }
    }

    func acceptRequest(_ request: ConnectionRequest) {
        updateRequestStatus(request, to: "accepted")
    }

    func rejectRequest(_ request: ConnectionRequest) {
        Task {
            do {
                try await supabase.database
                    .from("connections")
                    .delete()
                    .eq(column: "id", value: request.id.uuidString)
                    .execute()

                if let index = incomingRequests.firstIndex(where: { $0.id == request.id }) {
                    incomingRequests.remove(at: index)
                }
            } catch {
                print("Error rejecting request: \(error)")
            }
        }
    }
    
    func sendRequest(to username: String) {
        Task {
            do {
                let session = try await supabase.auth.session
                let requesterId = session.user.id
                
                
                struct ProfileResponse: Decodable {
                    let id: UUID
                }
                
                let response: [ProfileResponse] = try await supabase.database
                    .from("profiles")
                    .select(columns: "id")
                    .eq(column: "username", value: username)
                    .execute()
                    .value
                
                guard let addressee = response.first else {
                    print("User not found")
                    return
                }

                let newConnection = Connection(requester_id: requesterId, addressee_id: addressee.id, status: "pending")
                try await supabase.database
                    .from("connections")
                    .insert(values: newConnection)
                    .execute()
                
            } catch {
                print("Error sending request: \(error)")
            }
        }
    }

    private func doesConnectionExist(requesterId: UUID, addresseeUsername: String) async -> Bool {
        do {
            
            struct ProfileResponse: Decodable {
                let id: UUID
            }
            
            let response: [ProfileResponse] = try await supabase.database
                .from("profiles")
                .select(columns: "id")
                .eq(column: "username", value: addresseeUsername)
                .execute()
                .value
            
            guard let addressee = response.first else {
                return false
            }
            
            let count: Int = try await supabase.database
                .from("connections")
                .select(columns: "*", head: true)
                .or(filters: "requester_id.eq.\(requesterId),addressee_id.eq.\(requesterId)")
                .or(filters: "requester_id.eq.\(addressee.id),addressee_id.eq.\(addressee.id)")
                .execute()
                .count!
            
            return count > 0
        } catch {
            print("Error checking for connection: \(error)")
            return false
        }
    }

    private func updateRequestStatus(_ request: ConnectionRequest, to newStatus: String) {
        Task {
            do {
                print(request.id)
                try await supabase.database
                    .from("connections")
                    .update(values: ["status": newStatus])
                    .eq(column: "id", value: request.id)
                    .execute()
                
                if newStatus == "accepted" {
                    let reciprocalConnection = Connection(requester_id: request.addressee_id, addressee_id: request.requester_id, status: "accepted")
                    try await supabase.database
                        .from("connections")
                        .insert(values: reciprocalConnection)
                        .execute()
                }

                if let index = incomingRequests.firstIndex(where: { $0.id == request.id }) {
                    incomingRequests.remove(at: index)
                }

                if newStatus == "accepted" {
                    fetchFriends()
                }
            } catch {
                print("Error updating request status: \(error)")
            }
        }
    }

    func fetchFriends() {
        Task {
            do {
                self.friends = try await SupabaseManager.shared.getFriends()
            } catch {
                print("Error fetching friends: \(error)")
            }
        }
    }

    func meet(friend: Profile) {
        Task {
            do {
                let session = try await supabase.auth.session
                let userId = session.user.id

                self.meetingFriend = friend

                let body: [String: String] = [
                    "user_id": userId.uuidString,
                    "friend_id": friend.id.uuidString
                ]
                let options = FunctionInvokeOptions(body: body)

                struct MidpointResponse: Decodable {
                    let midpoint_lat: Double
                    let midpoint_lon: Double
                }

                let response: MidpointResponse = try await supabase.functions
                    .invoke(functionName: "get-midpoint", invokeOptions: options)

                self.meetingPoint = CLLocationCoordinate2D(latitude: response.midpoint_lat, longitude: response.midpoint_lon)

            } catch {
                print("Error calculating midpoint: \(error)")
            }
        }
    }
} 

