//
//  WeatherController.swift
//  weather
//
//  Created by Gabriela Sillis on 28/07/21.
//

import Foundation
import Alamofire

// MARK: - WeatherError
enum WeatherError: Error, LocalizedError {
    case cityNotFound(_ description: String)
    
    var errorDescription: String? {
        switch self {
        case .cityNotFound(let error):
            return error
        }
    }
}

struct WeatherController {
    // MARK: - Get API key from .plist file
    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "API_KEY", ofType: "plist") else {
            fatalError("Couldn't find file 'API_KEY'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'API_KEY.plist'.")
        }
        return value
        
    }
    
    func fetchWeather(city: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let query = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city
        let path = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric&lang=pt_br"
        let urlString = String(format: path, query, apiKey)
        handleResquest(urlString: urlString, completion: completion)
        
    }
    
    func fetchWeatherByLatAndLon(lati: Double, long: Double, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        let path = """
                        https://api.openweathermap.org/data/2.5/weather?&appid=%@&units=metric&lang=pt_br&lat=%f&lon=%f
                        """
        let urlString = String(format: path, apiKey, lati, long)
        handleResquest(urlString: urlString, completion: completion)
    }
    
    private func handleResquest(urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        AF.request(urlString)
            .validate()
            .responseDecodable(of: WeatherData.self, queue: .main, decoder: JSONDecoder()) { response in
                switch response.result {
                case .success(let weatherData):
                    let model = weatherData.model
                    completion(.success(model))
                case .failure(let error):
                    if let failure = getWeatherError(error, response.data) {
                        completion(.failure(failure))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    private func getWeatherError(_ error: AFError,_ data: Data?) -> Error? {
        if error.responseCode == 404,
           let data = data,
           let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) {
            let message = failure.message
            return WeatherError.cityNotFound(message)
        } else {
            return nil
        }
    }
}
