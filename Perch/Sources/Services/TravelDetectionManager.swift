import Foundation
import CoreLocation
import Combine

/// Monitors location changes to automatically detect travel
/// and prompt the user "Are you on a trip?"
@MainActor
final class TravelDetectionManager: ObservableObject {
    @Published var shouldPromptTravel = false
    @Published var travelPromptCity: String?
    @Published var travelPromptCountry: String?
    @Published var detectedLocation: CLLocation?
    
    private var homeLocation: CLLocation?
    private let homeLocationLatKey = "perch_home_lat"
    private let homeLocationLonKey = "perch_home_lon"
    private var visitObserver: Any?
    
    /// Distance threshold in meters to consider user "traveling" (100km)
    private let travelThreshold: Double = 100_000
    
    /// Distance threshold to consider user "back home" (30km)
    private let homeThreshold: Double = 30_000
    
    /// Whether home location has been set
    var hasHomeLocation: Bool {
        UserDefaults.standard.double(forKey: homeLocationLatKey) != 0
    }
    
    init() {
        loadHomeLocation()
        setupNotificationObserver()
    }
    
    private func loadHomeLocation() {
        let lat = UserDefaults.standard.double(forKey: homeLocationLatKey)
        let lon = UserDefaults.standard.double(forKey: homeLocationLonKey)
        if lat != 0 && lon != 0 {
            homeLocation = CLLocation(latitude: lat, longitude: lon)
        }
    }
    
    func setHomeLocation(_ location: CLLocation) {
        homeLocation = location
        UserDefaults.standard.set(location.coordinate.latitude, forKey: homeLocationLatKey)
        UserDefaults.standard.set(location.coordinate.longitude, forKey: homeLocationLonKey)
    }
    
    private func setupNotificationObserver() {
        visitObserver = NotificationCenter.default.addObserver(
            forName: .didRecordNewVisit,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let userInfo = notification.userInfo,
                  let latitude = userInfo["latitude"] as? Double,
                  let longitude = userInfo["longitude"] as? Double else { return }
            let city = userInfo["city"] as? String
            let country = userInfo["country"] as? String
            let loc = CLLocation(latitude: latitude, longitude: longitude)
            Task { @MainActor in
                self?.handleNewVisit(location: loc, city: city, country: country)
            }
        }
    }

    func cleanup() {
        if let observer = visitObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func handleNewVisit(location: CLLocation, city: String?, country: String?) {
        self.detectedLocation = location
        
        // Set home location on first ever location if not set
        if !hasHomeLocation {
            setHomeLocation(location)
            return
        }
        
        // If user already has an active trip, don't prompt
        // (This check happens in the view layer via tripStore.activeTrip)
        
        self.travelPromptCity = city
        self.travelPromptCountry = country
        
        // Check distance from home
        if let home = self.homeLocation {
            let distance = location.distance(from: home)
            if distance >= self.travelThreshold {
                self.shouldPromptTravel = true
            }
        }
    }
    
    /// Check if user is near home (for auto-end)
    func checkIfNearHome(currentLocation: CLLocation) -> Bool {
        guard let home = homeLocation else { return false }
        return currentLocation.distance(from: home) < homeThreshold
    }
    
    /// Call this when user dismisses the prompt (starts a trip or ignores)
    func dismissTravelPrompt() {
        shouldPromptTravel = false
        travelPromptCity = nil
        travelPromptCountry = nil
    }
    
    /// Call this to snooze the prompt (will re-prompt after 2 hours if new city detected)
    func snoozeTravelPrompt() {
        shouldPromptTravel = false
        travelPromptCity = nil
        travelPromptCountry = nil
    }
}
