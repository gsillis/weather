//
//  WeatherController.swift
//  weather
//
//  Created by Gabriela Sillis on 05/08/21.
//

import Foundation
import  CoreLocation

protocol  WeatherControllerDelegate: AnyObject {
    func updateView(with data: WeatherModel)
    func handleError(_ error: Error)
}

class WeatherController {

    private let weatherNetwork: WeatherNetwork = WeatherNetwork()
    private let locationController: LocationController = LocationController()

    weak var delegate: WeatherControllerDelegate?


    func fetchWeather(by city: String) {
        self.weatherNetwork.fetchWeatherByCity(city: city) { result in
            self.handleResult(result)
        }
    }

    func fetchWeatherByLocation(location: CLLocation) {
        let lati = location.coordinate.latitude
        let long = location.coordinate.longitude
        self.weatherNetwork.featchWeatherByLocation(lati: lati, long: long) { result in

            // espera para atualizar a view - assim é possível ver o skeletonview
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.handleResult(result)
            }
        }
    }

    private func handleResult(_ result: Result<WeatherModel, Error>) {
        switch result {
        case.success(let model):
            self.delegate?.updateView(with: model)

        case.failure(let error):
            self.delegate?.handleError(error)
        }
    }
}
