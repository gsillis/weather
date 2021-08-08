//
//  AddCityViewController.swift
//  weather
//
//  Created by Gabriela Sillis on 30/07/21.
//

import UIKit
import Lottie

protocol AddCityViewControllerDelegate: AnyObject {
    func didUpdateViewFromSearch(model: WeatherModel)
}

class AddCityViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var cityNameTextField: UITextField!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var weatherStackView: UIStackView!

    // MARK: - Properties
    private var weatherNetwork: WeatherNetwork = WeatherNetwork()
    weak var delegate: AddCityViewControllerDelegate?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayoutView()
        self.addTapGesture()
        self.hiddenStatusLabel()
        self.weatherStackView.addStackLottieAnimation("weather-sunny", index: 0)
        self.cityNameTextField.delegate = self
    }


    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.cityNameTextField.becomeFirstResponder()
    }


    
    // MARK: - searchButtonTapped
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        guard let textField = cityNameTextField.text, !textField.isEmpty else {
            self.showSearchError(text: "É necessário inserir uma cidade para realizar a busca")
            return }
        self.hiddenStatusLabel()
        self.handleSearch(city: textField)
        
        // dismiss do teclado ao clicar no botão
        self.view.endEditing(true)
    }

        
    // MARK: - Layout View
    private func setupLayoutView() {
        self.backgroundView.layer.cornerRadius = 10
        self.searchButton.layer.cornerRadius = 10
        view.backgroundColor = UIColor(white: 0.3, alpha: 0.4)
        self.cityNameTextField.layer.cornerRadius = 10
    }
    
    // MARK: - Fetch Weather
    private func handleSearch(city: String) {
        self.loadingActivityIndicator.startAnimating()
        
        self.weatherNetwork.fetchWeatherByCity(city: city) { [weak self] result in
            guard let view = self else { return }
            switch result {
            case.success(let model):
                view.searchSuccess(model: model)
            case.failure(let error):
                view.loadingActivityIndicator.stopAnimating()
                // mensagem de erro é definida pelo controller
                view.showSearchError(text: error.localizedDescription)
            }
        }
    }
    
    private func searchSuccess(model: WeatherModel) {
        
        /*aguarda 1 seg para atualizar - foi feito isso para ser possível
        ver o efeito do ActivityIndicator */
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let view = self else { return }
            view.delegate?.didUpdateViewFromSearch(model: model)
            view.loadingActivityIndicator.stopAnimating()
        }
    }
    
    // setup da mensagem de erro
    private func showSearchError(text: String) {
        self.statusLabel.isHidden = false
        self.statusLabel.text = text
    }
    
    private func hiddenStatusLabel() {
        self.statusLabel.isHidden = true
    }


    
    // MARK: - UITapGestureRecognizer
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViewController() {
        // dissmiss no vc ao clicar fora do box
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - extension UIGestureRecognizerDelegate
extension AddCityViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // reconhe a vc ao clicar fora do box
        return touch.view == self.view
    }
}

// MARK: - extension UITextFieldDelegate
extension AddCityViewController: UITextFieldDelegate {
    // dismiss no keyboard ao clicar em return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
