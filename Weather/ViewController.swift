//
//  ViewController.swift
//  Weather
//
//  Created by 요시킴 on 2024/01/18.
//

import UIKit

class ViewController: UIViewController {
    
    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 5.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "입력하세요"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    let location: UILabel = {
        let label = UILabel()
        label.text = "지역"
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }()
    
    let currentWeather: UILabel = {
        let label = UILabel()
        label.text = "현재날씨"
        return label
    }()
    
    let temperature: UILabel = {
        let label = UILabel()
        label.text = "현재온도"
        label.font = UIFont.systemFont(ofSize: 25)
        return label
    }()
    
    let lowestTemperature: UILabel = {
        let label = UILabel()
        label.text = "최저온도"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    let highestTemperature: UILabel = {
        let label = UILabel()
        label.text = "최고온도"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    lazy var temperatureStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [lowestTemperature, highestTemperature])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [location, currentWeather, temperature, temperatureStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(weatherImageView)
        view.addSubview(textField)
        view.addSubview(button)
        view.addSubview(stackView)
        textFieldLayout()
        buttonLayout()
        stackViewLayout()
        imageViewLayout()
    }
    
    func imageViewLayout() {
        NSLayoutConstraint.activate([
            weatherImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            weatherImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            weatherImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            weatherImageView.widthAnchor.constraint(equalTo: weatherImageView.heightAnchor)
        ])
    }
    
    func textFieldLayout() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor, constant: 20),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            textField.heightAnchor.constraint(equalToConstant: 30),
        ])    }
    
    func buttonLayout() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
            button.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    func stackViewLayout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc func buttonTapped() {
        if let cityName = self.textField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.location.text = weatherInformation.name
        if let weather = weatherInformation.weather.first {
            self.currentWeather.text = weather.description
        }
        self.temperature.text = "\(Int(weatherInformation.temp.temp - 273.15))°C"
        self.lowestTemperature.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))°C"
        self.highestTemperature.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))°C"
        
    }
    
    func showAlert (message: String) {
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=e5ee6442873bdeda8dd2922c2d7b516a"
        ) else { return }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) {
            [weak self] data, response, error in
            let successRange = (200..<300)
            
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()
            
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else {
                    return }
                
                if let weather = weatherInformation.weather.first,
                   let iconCode = weather.icon {
                    self?.loadWeatherIcon(iconCode: iconCode)
                }
                
                DispatchQueue.main.async {
                    self?.stackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
            } else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message)
                }
            }
        }.resume()
    }
    
    func loadWeatherIcon(iconCode: String) {
        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode).png")
        URLSession.shared.dataTask(with: iconURL!) { data, _, error in
            guard let data = data, error == nil else { return }
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.weatherImageView.image = image
                }
            }
        }.resume()
    }
}
