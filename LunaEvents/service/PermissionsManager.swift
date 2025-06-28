//
//  PermissionsManager.swift
//  LunaEvents_app
//
//  Created by K on 6/28/25.
//

import Foundation
import EventKit
import CoreLocation

class PermissionsManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var calendarPermissionStatus: EKAuthorizationStatus = .notDetermined
    @Published var userLocation: CLLocation?
    
    private let locationManager = CLLocationManager()
    private let eventStore = EKEventStore()
    
    static let shared = PermissionsManager()
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkAllPermissions() {
        checkLocationPermission()
        checkCalendarPermission()
    }
    
    // MARK: - Location Permissions
    
    func checkLocationPermission() {
        locationPermissionStatus = locationManager.authorizationStatus
        switch locationPermissionStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        case .notDetermined:
            requestLocationPermission()
        default:
            break
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Calendar Permissions
    
    func checkCalendarPermission() {
        calendarPermissionStatus = EKEventStore.authorizationStatus(for: .event)
        if calendarPermissionStatus == .notDetermined {
            requestCalendarPermission()
        }
    }
    
    func requestCalendarPermission() {
        eventStore.requestFullAccessToEvents { (granted, error) in
            DispatchQueue.main.async {
                self.calendarPermissionStatus = EKEventStore.authorizationStatus(for: .event)
            }
        }
    }
    
    func createCalendarEvent(with coordinates: CLLocationCoordinate2D, friendName: String) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }

            let placeName = placemarks?.first?.name ?? "Meeting Point"

            if self.calendarPermissionStatus == .fullAccess {
                let event = EKEvent(eventStore: self.eventStore)
                event.title = "Meetup with \(friendName) at \(placeName)"
                event.startDate = Date().addingTimeInterval(2 * 60 * 60) // 2 hours from now
                event.endDate = event.startDate.addingTimeInterval(60 * 60) // 1 hour duration
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                
                let structuredLocation = EKStructuredLocation(title: placeName)
                structuredLocation.geoLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                event.structuredLocation = structuredLocation
                
                do {
                    try self.eventStore.save(event, span: .thisEvent)
                    print("Event saved successfully.")
                } catch {
                    print("Error saving event: \(error)")
                }
            } else {
                print("Calendar access is not granted.")
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationPermissionStatus = manager.authorizationStatus
        print("Location authorization status changed to: \(locationPermissionStatus.rawValue)")
        if locationPermissionStatus == .authorizedWhenInUse || locationPermissionStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        self.userLocation = location
        print("Location found: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        Task {
            await SupabaseManager.shared.updateLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        
        locationManager.stopUpdatingLocation()
        print("Stopped updating location.")
    }
} 
