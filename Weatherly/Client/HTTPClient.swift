//
//  HTTPClient.swift
//  Weatherly
//
//  Created by bartek on 27/11/2023.
//

import UIKit
import Combine
import CoreLocation


enum NetworkError: Error {
    case badUrl
}

class HTTPClient {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=f5bcc71537ea4f9e4fe293290a49f0be&units=metric"
    
    func fetchWeather(cityName: String) -> AnyPublisher<WeatherModel, Error> {
        guard let encodedString = cityName.urlEncoded, let url = URL(string: "\(weatherURL)&q=\(encodedString)") else {
            return Fail(error: NetworkError.badUrl).eraseToAnyPublisher()
        }
        print("url = \(url)")
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .tryMap{ weatherData in
                let id = weatherData.weather[0].id
                let temp = weatherData.main.temp
                let name = weatherData.name
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                return weather
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> AnyPublisher<WeatherModel, Error> {
        guard let url = URL(string:"\(weatherURL)&lat=\(latitude)&lon=\(longitude)") else {
            return Fail(error: NetworkError.badUrl).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .tryMap{ weatherData in
                let id = weatherData.weather[0].id
                let temp = weatherData.main.temp
                let name = weatherData.name
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                
                return weather
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

