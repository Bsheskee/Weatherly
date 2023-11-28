//
//  WeatherViewModel.swift
//  Weatherly
//
//  Created by bartek on 27/11/2023.
//

import UIKit
import Combine
import CoreLocation

class WeatherViewModel {
    @Published private(set) var weatherModel: WeatherModel
    private var cancellables: Set<AnyCancellable> = []
    @Published var updatingCompleted: Bool = false
    
    private var searchSubject = CurrentValueSubject<String, Never>("")

    private let httpClient: HTTPClient

    init(httpClient: HTTPClient, weatherModel: WeatherModel) {
        self.httpClient = httpClient
        self.weatherModel = weatherModel
        setupSearchPublisher()
    }

    func updateWeather(cityName: String) {
        httpClient.fetchWeather(cityName: cityName)
            .sink {  [weak self] completion in
                switch completion {
                case .finished:
                    self?.updatingCompleted = true
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] model in
                self?.weatherModel = model
            }.store(in: &cancellables)
    }
    func updateWeather(lat: CLLocationDegrees, long: CLLocationDegrees) {
        httpClient.fetchWeather(latitude: lat, longitude: long)
            .sink {  [weak self] completion in
                switch completion {
                case .finished:
                    self?.updatingCompleted = true
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] model in
                self?.weatherModel = model
            }.store(in: &cancellables)
    }
    private func setupSearchPublisher() {
        searchSubject
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] searchtext in
                self?.updateWeather(cityName: searchtext)
            }.store(in: &cancellables)
    }
    func setSearchText(_ searchText: String) {
        let englishOnlyText = filterNonEnglishCharacters(from: searchText)
        searchSubject.send(englishOnlyText)
    }
    private func filterNonEnglishCharacters(from text: String) -> String {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+")
        var englishOnlyText = text

        let latinTransform = StringTransform(rawValue: "Latin-ASCII")
        englishOnlyText = englishOnlyText.applyingTransform(latinTransform, reverse: false) ?? englishOnlyText
        

        let filteredText = englishOnlyText.components(separatedBy: allowedCharacters.inverted).joined(separator: "")
        return filteredText
    }
    var weatherModelPublisher: Published<WeatherModel>.Publisher { $weatherModel }
}
