//
//  ViewController.swift
//  Weatherly
//
//  Created by bartek on 26/11/2023.
//

import UIKit
import SwiftUI
import CoreLocation
import Combine

class WeatherVC: UIViewController {

    private var viewModel: WeatherViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var searchedCity: String?
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let locationManager = CLLocationManager()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Enter city"
        
        if self.traitCollection.userInterfaceStyle == .dark {
            searchBar.barTintColor = UIColor(named: "barBackground")
            searchBar.searchTextField.backgroundColor = UIColor(named: "barTextField")
            searchBar.searchTextField.textColor = UIColor(named: "Accent")
        } else {
            searchBar.searchTextField.backgroundColor = UIColor(named: "barTextField")
            searchBar.barTintColor = UIColor(named: "barBackground")
        }
        return searchBar
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "Accent")
        label.font = UIFont(name: "Arial", size: 35)
        label.text = label.text?.uppercased()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "Accent")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 60, weight: .black)
        return label
    }()
    private let celsiusLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "Accent")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 60, weight: .medium)
        label.text = "°C"
        return label
    }()
    private let conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(named: "Accent")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let navigateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "Accent")
        button.addTarget(self, action: #selector(navigateButtonPressed), for: .touchUpInside)
        return button
    }()
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = UIColor(named: "Accent")
        button.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        return button
    }()
    private lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView(frame: self.view.frame)
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupUI()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        view.backgroundColor = .white
        
        viewModel.weatherModelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                self?.conditionImageView.image = UIImage(systemName: model.conditionName)
                self?.cityLabel.text = model.cityName
                self?.temperatureLabel.text = model.temperatureString
            }.store(in: &cancellables)
    }
    private func setupUI() {
//        view.addSubview(backgroundImage)
        view.addSubview(searchBar)
        view.addSubview(cityLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(celsiusLabel)
        view.addSubview(conditionImageView)
        view.addSubview(navigateButton)
        view.addSubview(searchButton)
        view.insertSubview(backgroundImage, at: 0)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        celsiusLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionImageView.translatesAutoresizingMaskIntoConstraints = false
        navigateButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImage.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 150),
            backgroundImage.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 150),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -80),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor, constant: -80),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: navigateButton.trailingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 40),
            navigateButton.heightAnchor.constraint(equalToConstant: 40),
            navigateButton.widthAnchor.constraint(equalToConstant: 40),
            navigateButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            navigateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchButton.heightAnchor.constraint(equalToConstant: 40),
            searchButton.widthAnchor.constraint(equalToConstant: 40),
            cityLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
            cityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            cityLabel.widthAnchor.constraint(equalToConstant: 160),
            temperatureLabel.topAnchor.constraint(equalTo: conditionImageView.bottomAnchor, constant: 20),
            temperatureLabel.trailingAnchor.constraint(equalTo: celsiusLabel.leadingAnchor, constant: 0),
            celsiusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            celsiusLabel.bottomAnchor.constraint(equalTo: temperatureLabel.bottomAnchor),
            conditionImageView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            conditionImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            conditionImageView.heightAnchor.constraint(equalToConstant: 150),
            conditionImageView.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    @objc func navigateButtonPressed() {
        locationManager.requestLocation()
    }
    @objc func searchButtonPressed() {
        if let searchedCity = searchedCity {
            viewModel.setSearchText(searchedCity)
        } else {
            print("searchedCity is nil")
        }
    }
}
extension WeatherVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            viewModel.updateWeather(lat: lat, long: long)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
extension WeatherVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        viewModel.setSearchText(searchText.urlEncoded!)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCity = searchText.urlEncoded
        print(searchedCity!)
    }
}
#if canImport(SwiftUI) && DEBUG
struct WeatherVCRepresentable: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = WeatherVC
    
    func updateUIViewController(_ uiViewController: WeatherVC, context: Context) {
    }
    
    func makeUIViewController(context: Context) -> WeatherVC {
        WeatherVC(viewModel: WeatherViewModel(httpClient: HTTPClient(), weatherModel: WeatherModel(conditionId: 200, cityName: "City Name", temperature: 2)))
    }
}
@available(iOS 13.0, *)
struct WeatherVC_Preview: PreviewProvider {
    static var previews: some View {
        WeatherVCRepresentable()
    }
}
#endif
