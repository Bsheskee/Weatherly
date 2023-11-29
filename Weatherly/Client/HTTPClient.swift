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
    case connectionError
}

class HTTPClient {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=f5bcc71537ea4f9e4fe293290a49f0be&units=metric"
    
    func fetchWeather(latitude: CLLocationDegrees? = nil, longitude: CLLocationDegrees? = nil, cityName: String? = nil) -> AnyPublisher<WeatherModel, Error> {
        var urlString = weatherURL
        
        if let cityName = cityName, let encodedString = cityName.urlEncoded {
            urlString += "&q=\(encodedString)"
        } else if let latitude = latitude, let longitude = longitude {
            urlString += "&lat=\(latitude)&lon=\(longitude)"
        } else {
            // Handle invalid input or provide a default behavior
            return Fail(error: NetworkError.badUrl).eraseToAnyPublisher()
        }
        
        guard let url = URL(string: urlString) else {
            return Fail(error: NetworkError.badUrl).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: WeatherData.self, decoder: JSONDecoder())
            .tryMap { weatherData in
                let id = weatherData.weather[0].id
                let temp = weatherData.main.temp
                let name = weatherData.name
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                
                return weather
            }
            .receive(on: DispatchQueue.main)
            .catch { error -> AnyPublisher<WeatherModel, Error> in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

