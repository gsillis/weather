//
//  ViewController.swift
//  weather
//
//  Created by Gabriela Sillis on 28/07/21.
//

import UIKit
import SkeletonView
import CoreLocation
import Loaf

class WeatherViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var weatherForecastImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    // MARK: - Properties
    private var weatherController = WeatherController()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchWeather(by: "São Paulo")
    }

    // MARK: - IBAction
    @IBAction func locationButtonTapped(_ sender: Any) {
        self.locationManagerDidChangeAuthorization(self.locationManager)
    }
    
    @IBAction func addCityButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showAddCity", sender: nil)
    }
    
    // MARK: - fetchWeather by city
    private func fetchWeather(by city: String) {
        self.showAnimatedSkeleton()
        weatherController.fetchWeatherByCity(city: city) { result in
            self.handleResult(result)
        }
    }
    
    // MARK: - fetchWeather by location
    private func featchWeatherByLocation(location: CLLocation) {
        self.showAnimatedSkeleton()
        let lati = location.coordinate.latitude
        let long = location.coordinate.longitude
        weatherController.featchWeatherByLocation(lati: lati, long: long) { result in
            
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
            self.updateView(with: model)
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
        navigationItem.title = ""
        Loaf(error.localizedDescription, state: .error, location: .top, sender: self).show()
    }
    
    // MARK: - Skeleton Animation
    private func showAnimatedSkeleton() {
        weatherForecastImage.showAnimatedSkeleton()
        temperatureLabel.showAnimatedSkeleton()
        conditionLabel.showAnimatedSkeleton()
    }
    
    private func hideAnimation() {
        weatherForecastImage.hideSkeleton()
        temperatureLabel.hideSkeleton()
        conditionLabel.hideSkeleton()
    }
    
    // MARK: - updateView
    private func updateView(with data: WeatherModel) {
        // atualiza as labels e imagem da view e pausa a animação
        self.hideAnimation()
        self.temperatureLabel.text = data.temp.toString().appending("°C")
        self.weatherForecastImage.image = UIImage(named: data.conditionImage)
        self.conditionLabel.text = data.conditionDescription
        self.navigationItem.title = data.cityName
    }
    
    // MARK: - perfom segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
    }
    
    // MARK: - Alert showPermission
    private func showPermission() {
        let title: String =  "Autorizar uso da localização"
        let message: String = "Deseja autorizar o uso da localização"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Autorizar", style: .default) { _ in
            // abre o settings do dispositivo ao clicar na action
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
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
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.featchWeatherByLocation(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleError(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            case .notDetermined:
                locationManager.requestLocation()
                locationManager.requestWhenInUseAuthorization()
            default:
                showPermission()
        }
    }
}
