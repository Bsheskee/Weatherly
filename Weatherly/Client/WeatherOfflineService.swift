//
//  WeatherOfflineService.swift
//  Weatherly
//
//  Created by bartek on 29/11/2023.
//

import Foundation
import Combine

enum DataRetrievalError: Error {
    case noDataStored
    case decodingError
}

class WeatherOfflineService {
    
    private let defaults = UserDefaults.standard
    private let key = "weather"
    
    func saveOffline(weather: WeatherModel) {
        if let encoded: Data = try? JSONEncoder().encode(weather) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func getOffline() -> AnyPublisher<WeatherModel, Error> {
        do {
            guard let data: Data = defaults.object(forKey: key) as? Data else {
                return Fail(error: DataRetrievalError.noDataStored).eraseToAnyPublisher()
            }
            let decoded: WeatherModel
            
            do {
                decoded = try JSONDecoder().decode(WeatherModel.self, from: data)
            } catch {
                throw DataRetrievalError.decodingError
            }
            return Just(decoded)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
