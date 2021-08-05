//
//  WeatherData.swift
//  weather
//
//  Created by Gabriela Sillis on 28/07/21.
//

import Foundation

struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
    
    var model: WeatherModel {
        return WeatherModel(cityName: name,
                            temp: main.temp.toInt(),
                            conditionId: weather.first?.id ?? 0,
                            conditionDescription: weather.first?.description ?? "")
    }
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
    let main, description: String
}

struct WeatherModel {
    let cityName: String
    let temp: Int
    let conditionId: Int
    let conditionDescription: String
    
    var conditionImage: String {
        
        switch conditionId {
        case 200...232:
            return "imThunderstorm"
        case 300...321:
            return "imDrizzle"
        case 500...531:
            return "imRain"
        case  600...622:
            return "imSnow"
        case  701...781:
            return "imAtmosphere"
        case  801...804:
            return "imClouds"
        default:
            return "imClear"
        }
    }
    
    var conditionBackground: String {
        switch conditionId {
        case 200...232:
            return "Thunderstorm"
        case 300...321:
            return "Drizzle"
        case 500...531:
            return "Rain"
        case  600...622:
            return "Snow"
        case  701...781:
            return "Atmosphere"
        case  801...804:
            return "Clouds"
        default:
            return "Clear"
        }
    }
}
