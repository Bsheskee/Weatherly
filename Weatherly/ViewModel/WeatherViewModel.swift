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
    @Published private(set) var weatherModel: WeatherModel?
    private var cancellables: Set<AnyCancellable> = []
    @Published var updatingCompleted: Bool = false
    
    private var searchSubject = CurrentValueSubject<String, Never>("")

    private let httpClient: HTTPClient
    private let offlineService: WeatherOfflineService = .init()
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
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
                    self?.weatherModel = nil
                }
            } receiveValue: { [weak self] model in
                self?.weatherModel = model
            }.store(in: &cancellables)
    }
    func updateWeather(lat: CLLocationDegrees, long: CLLocationDegrees) {
        httpClient.fetchWeather(latitude: lat, longitude: long).catch { [weak self] error in
            return self?.offlineService.getOffline() ?? Empty().eraseToAnyPublisher()
        }.handleEvents(receiveOutput: { [weak self] weatherData in
            self?.offlineService.saveOffline(weather: weatherData)
        }).eraseToAnyPublisher()
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
    internal func filterNonEnglishCharacters(from text: String) -> String { //set internal for testing
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+")
        var englishOnlyText = text

        let latinTransform = StringTransform(rawValue: "Latin-ASCII")
        englishOnlyText = englishOnlyText.applyingTransform(latinTransform, reverse: false) ?? englishOnlyText
        

        let filteredText = englishOnlyText.components(separatedBy: allowedCharacters.inverted).joined(separator: "")
        return filteredText
    }
    var weatherModelPublisher: AnyPublisher<WeatherModel?, Never> {
           return $weatherModel.eraseToAnyPublisher()
       }
    var isWeatherAvailable: Bool {
            return weatherModel != nil
        }
}
