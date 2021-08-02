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

    //MARK: - IBOutlet
    @IBOutlet weak var weatherForecastImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    //MARK: - Properties
    private var weatherController = WeatherController()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showAnimatedSkeleton()
        self.fetchWeather()
    }

    //MARK: - IBAction
    @IBAction func locationButtonTapped(_ sender: Any) {}
    
    @IBAction func addCityButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showAddCity", sender: nil)
    }
    
    //MARK: - fetchWeather
    private func fetchWeather() {
        self.weatherController.fetchWeather(city: "curitiba") { [weak self] result in
            guard let view = self else { return }
            switch result {
            case.success(let model):
                view.updateView(with: model)
            case.failure(let error):
                print("error \(error)")
            }
        }
    }
    
    //MARK: - Skeleton Animation
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
    
    //MARK: - updateView
    private func updateView(with data: WeatherModel) {
        //atualiza as labels e imagem da view e pausa a animação
        self.hideAnimation()
        self.temperatureLabel.text = data.temp.toString().appending("°C")
        self.weatherForecastImage.image = UIImage(named: data.conditionImage)
        self.conditionLabel.text = data.conditionDescription
        self.navigationItem.title = data.cityName
    }
    
    //MARK: - perfom segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddCityViewController {
                destination.delegate = self
            }
        }
    }
}

//MARK: - Protocol
extension WeatherViewController: AddCityViewControllerDelegate {
    func didUpdateViewFromSearch(model: WeatherModel) {
        //dismiss no addCityVc e update da weatherVc
        presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let view = self else { return }
            view.updateView(with: model)
        })
    }
}
