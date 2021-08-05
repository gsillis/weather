//
//  LocationController.swift
//  weather
//
//  Created by Gabriela Sillis on 05/08/21.
//

import CoreLocation

// MARK: - Protocol
protocol LocationControllerDelegate: AnyObject {
    func locationManager(didUpdateLocations locations: CLLocation)
    func locationManager(didFailWithError error: Error)
}

protocol LocationType: AnyObject {
    var delegate: LocationControllerDelegate? { get set }
    func requestLocationUsage()
}

class LocationController: NSObject, LocationType {
    weak var delegate: LocationControllerDelegate?
    private var locationManager: CLLocationManager = CLLocationManager()

    override init() {
        super.init()
        self.locationManagerDelegate()
    }

    private func locationManagerDelegate() {
        self.locationManager.delegate = self
    }

    func requestLocationUsage() {
    self.locationManager.requestLocation()
    self.locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.delegate?.locationManager(didUpdateLocations: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.locationManager(didFailWithError: error)
    }
}
