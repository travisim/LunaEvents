//
//  FriendsView.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import SwiftUI
import MapKit

enum MapAnnotationItem: Identifiable {
    case friend(Profile)
    case meetingPoint(CLLocationCoordinate2D)

    var id: String {
        switch self {
        case .friend(let profile):
            return profile.id.uuidString
        case .meetingPoint(let coordinate):
            return "\(coordinate.latitude)-\(coordinate.longitude)"
        }
    }

    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .friend(let profile):
            return CLLocationCoordinate2D(latitude: profile.lastLatitude!, longitude: profile.lastLongitude!)
        case .meetingPoint(let coordinate):
            return coordinate
        }
    }
}

struct AnnotationView: View {
    let item: MapAnnotationItem
    let permissionsManager: PermissionsManager
    let friendsViewModel: FriendsViewModel

    var body: some View {
        switch item {
        case .friend(let friend):
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                Text(friend.username.prefix(1).uppercased())
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            .contextMenu {
                Button("Meet") {
                    friendsViewModel.meet(friend: friend)
                }
            }
        case .meetingPoint(let coordinate):
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 30, height: 30)
                Image(systemName: "flag.fill")
                    .foregroundColor(.white)
            }
            .contextMenu {
                Button("Create Event") {
                    if let friend = friendsViewModel.meetingFriend {
                        permissionsManager.createCalendarEvent(with: coordinate, friendName: friend.username)
                    }
                }
            }
        }
    }
}

struct FriendsView: View {
    @EnvironmentObject var friendsViewModel: FriendsViewModel
    @StateObject private var permissionsManager = PermissionsManager.shared
    @State private var showsUserLocation = true
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    var body: some View {
        NavigationView {
            Map(
                coordinateRegion: $region,
                showsUserLocation: showsUserLocation,
                annotationItems: friendsViewModel.mapAnnotations
            ) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    AnnotationView(item: item, permissionsManager: permissionsManager, friendsViewModel: friendsViewModel)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                permissionsManager.checkLocationPermission()
            }
            .onChange(of: permissionsManager.userLocation) {
                if let location = permissionsManager.userLocation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )
                }
            }
            .navigationBarItems(trailing:
                NavigationLink(destination: AddConnectionView()) {
                    Image(systemName: "person.badge.plus")
                }
            )
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
