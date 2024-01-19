//
//  WeatherVC+UI.swift
//  Weatherly
//
//  Created by bartek on 19/01/2024.
//

import UIKit

extension WeatherVC {
    
    func startLoadingIndicator() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicatorView.startAnimating()
    }
    func removeLoadingIndicator() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
    func showUIComponents() {
        conditionImageView.isHidden = false
        cityLabel.isHidden = false
        temperatureLabel.isHidden = false
        celsiusLabel.isHidden = false
    }
    func hideUIComponents() {
        conditionImageView.isHidden = true
        cityLabel.isHidden = true
        temperatureLabel.isHidden = true
        celsiusLabel.isHidden = true
    }
    func setupUI() {
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
}
