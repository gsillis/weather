//
//  ViewController.swift
//  weather
//
//  Created by Gabriela Sillis on 28/07/21.
//

import UIKit
import SkeletonView
import CoreLocation

class WeatherViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var weatherForecastImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!

    
    
    // MARK: - Properties
    private let weatherNetwork: WeatherNetwork = WeatherNetwork()
    private let locationController: LocationController = LocationController()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchWeather(by: "São Paulo")
        self.locationController.delegate = self
    }

    // MARK: - IBAction
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        self.locationController.requestLocationUsage()
    }
    
    @IBAction func addCityButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddCity", sender: nil)
    }
    
    // MARK: - fetchWeather by city
    private func fetchWeather(by city: String) {
        self.showAnimatedSkeleton()
        self.weatherNetwork.fetchWeatherByCity(city: city) { result in
            self.handleResult(result)
        }
    }
    
    // MARK: - fetchWeather by location
    private func fetchWeatherByLocation(location: CLLocation) {
        showAnimatedSkeleton()
        let lati = location.coordinate.latitude
        let long = location.coordinate.longitude
        self.weatherNetwork.featchWeatherByLocation(lati: lati, long: long) { result in
            
            // espera para atualizar a view - assim é possível ver o skeletonview
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.handleResult(result)
            }
        }
    }
    
    // MARK: - handleResult
    private func handleResult(_ result: Result<WeatherModel, Error>) {
        switch result {
        case.success(let model):
                updateView(with: model)
        case.failure(let error):
                handleError(error)
        }
    }
    
    // MARK: - handleError
    private func handleError(_ error: Error) {
        self.hideAnimation()
        self.weatherForecastImage.image = UIImage(named: "imSad")
        self.temperatureLabel.text = "Ooops!"
        self.conditionLabel.text = "Algo deu errado, tente novamente."
        self.cityNameLabel.text = ""
        self.backgroundImage.image = UIImage(named: "Rain")
    }
    
    // MARK: - Skeleton Animation
    private func showAnimatedSkeleton() {
        self.weatherForecastImage.showAnimatedSkeleton()
        self.temperatureLabel.showAnimatedSkeleton()
        self.conditionLabel.showAnimatedSkeleton()
        self.cityNameLabel.showAnimatedSkeleton()
        self.backgroundImage.showAnimatedSkeleton()
    }
    
    private func hideAnimation() {
        self.weatherForecastImage.hideSkeleton()
        self.temperatureLabel.hideSkeleton()
        self.conditionLabel.hideSkeleton()
        self.cityNameLabel.hideSkeleton()
        self.backgroundImage.hideSkeleton()
    }
    
    // MARK: - updateView
    private func updateView(with data: WeatherModel) {
        // atualiza as labels e imagem da view e pausa a animação
        self.hideAnimation()
        self.temperatureLabel.text = data.temp.toString().appending("°C")
        self.weatherForecastImage.image = UIImage(named: data.conditionImage)
        self.conditionLabel.text = data.conditionDescription
        self.cityNameLabel.text = data.cityName
        self.backgroundImage.image = UIImage(named: data.conditionBackground)
    }
    
    // MARK: - perfom segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
    }
}

// MARK: - Protocol
extension WeatherViewController: AddCityViewControllerDelegate {
    func didUpdateViewFromSearch(model: WeatherModel) {
        // dismiss no addCityVc e update da weatherVc
        presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let view = self else { return }
            view.updateView(with: model)
        })
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: LocationControllerDelegate {

    func locationManager(didUpdateLocations locations: CLLocation) {
        self.fetchWeatherByLocation(location: locations)
    }

    func locationManager(didFailWithError error: Error) {
        self.handleError(error)
    }
}
