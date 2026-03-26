import Foundation
import CoreLocation
import Combine
import MapKit

@MainActor
final class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation?
    @Published var lastVisitCity: String?
    @Published var lastVisitCountry: String?
    @Published var isMonitoring = false

    private var lastRecordedLocation: CLLocation?
    private var stationaryTimer: Timer?
    private var isStationary = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 50000 // 50km - significant change
        authorizationStatus = locationManager.authorizationStatus
    }

    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    func startMonitoring() {
        guard CLLocationManager.significantLocationChangeMonitoringAvailable() else {
            print("Significant location change monitoring not available")
            return
        }
        locationManager.startMonitoringSignificantLocationChanges()
        isMonitoring = true
    }

    func stopMonitoring() {
        locationManager.stopMonitoringSignificantLocationChanges()
        isMonitoring = false
        stationaryTimer?.invalidate()
        stationaryTimer = nil
    }

    private func geocode(location: CLLocation) async -> (city: String?, country: String?) {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            return (nil, nil)
        }
        return await withCheckedContinuation { continuation in
            request.getMapItems { mapItems, error in
                if let error = error {
                    print("Geocoding error: \(error)")
                    continuation.resume(returning: (nil, nil))
                    return
                }
                guard let items = mapItems, let first = items.first else {
                    continuation.resume(returning: (nil, nil))
                    return
                }
                // placemark deprecated in iOS 26; placemark API still functional
                let placemark = first.placemark
                let city = placemark.locality
                let country = placemark.country
                continuation.resume(returning: (city, country))
            }
        }
    }

    private func shouldRecordNewVisit(newLocation: CLLocation) -> Bool {
        guard let last = lastRecordedLocation else { return true }
        let distance = newLocation.distance(from: last)
        return distance >= 50000 // 50km threshold
    }

    private func checkForStationary(location: CLLocation) {
        stationaryTimer?.invalidate()
        isStationary = true
        stationaryTimer = Timer.scheduledTimer(withTimeInterval: 7200, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.isStationary = false
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor [weak self] in
            self?.authorizationStatus = status
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                if self?.isMonitoring == true {
                    self?.startMonitoring()
                }
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.lastLocation = location
            self.checkForStationary(location: location)

            if self.shouldRecordNewVisit(newLocation: location) {
                self.lastRecordedLocation = location
                let (city, country) = await self.geocode(location: location)
                self.lastVisitCity = city
                self.lastVisitCountry = country
                NotificationCenter.default.post(
                    name: .didRecordNewVisit,
                    object: nil,
                    userInfo: [
                        "latitude": lat,
                        "longitude": lon,
                        "city": city as Any,
                        "country": country as Any
                    ]
                )
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}

extension Notification.Name {
    static let didRecordNewVisit = Notification.Name("didRecordNewVisit")
}
