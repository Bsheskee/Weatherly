//
//  ViewController.swift
//  Weatherly
//
//  Created by bartek on 26/11/2023.
//
// The preview updates are not showing the components due to being hidden initially. UIKit seems to not handle the preview as expected. To see UI please build it in the simulator.
//

import UIKit
import SwiftUI
import CoreLocation
import Combine

class WeatherVC: UIViewController {

    private var viewModel: WeatherViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var searchedCity: String?
    
    let locationManager = CLLocationManager()
    
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                startLoadingIndicator()
            } else {
                removeLoadingIndicator()
            }
        }
    }
    let activityIndicatorView: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            return indicator
        }()
    
     lazy var searchBar: UISearchBar = {
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
     let cityLabel: UILabel = {
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
     let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "Accent")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 60, weight: .black)
        return label
    }()
     let celsiusLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "Accent")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 60, weight: .medium)
        label.text = "°C"
        return label
    }()
     let conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(named: "Accent")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
     let navigateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "Accent")
        button.addTarget(self, action: #selector(navigateButtonPressed), for: .touchUpInside)
        return button
    }()
     let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = UIColor(named: "Accent")
        button.addTarget(self, action: #selector(searchButtonPressed), for: .touchUpInside)
        return button
    }()
     lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView(frame: self.view.frame)
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupUI()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        isLoading = true
        hideUIComponents()
        
        viewModel.weatherModelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
            if self?.viewModel.isWeatherAvailable == true {
                self?.isLoading = false
                    
                if let model = model {
                        self?.showUIComponents()
                        self?.conditionImageView.image = UIImage(systemName: model.conditionName)
                        self?.cityLabel.text = model.cityName
                        self?.temperatureLabel.text = model.temperatureString
                    }
                }
            }.store(in: &cancellables)
    }
   
    
    @objc func navigateButtonPressed() {
        locationManager.requestLocation()
    }
    @objc func searchButtonPressed() {
        if let searchedCity = searchedCity {
            viewModel.setSearchText(searchedCity)
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
    
    var isLoading: Bool
    
    func updateUIViewController(_ uiViewController: WeatherVC, context: Context) {
        uiViewController.isLoading = isLoading
    }
    
    func makeUIViewController(context: Context) -> WeatherVC {
        let vc = WeatherVC(viewModel: WeatherViewModel(httpClient: HTTPClient()))
        vc.isLoading = false
        return vc
    }
}
@available(iOS 13.0, *)
struct WeatherVC_Preview: PreviewProvider {
    static var previews: some View {
        WeatherVCRepresentable(isLoading: false)
    }
}
#endif
