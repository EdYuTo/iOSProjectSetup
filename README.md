# WeatherApp

## Objective

Build a simple iOS weather app that fetches weather data from a public API and displays it to the user in a user-friendly interface

## Requirements

* The use of the [OpenWeatherMap API](https://openweathermap.org/api) to fetch weather data
* Support of **iOS 15** and up
* At least two screens:
  * Screen 1: Users can enter the name of a city to get the current weather information
  * Screen 2: Display the retrieved weather information, including at least temperature, weather description, and an icon representing the weather condition
* Search field should present suggestions for locations as user types in city name or zipcode
* Error handling for cases such as no internet connection or invalid city names
* Refresh mechanism to update the weather data
* Use of Swift and best practices for iOS development
* Comments when necessary
* One screen using SwiftUI and one screen using UIKit

## Extra
* Unit tests
* Unit configuration (e.g celsius x fahrenheit)
* Use of design patterns (e.g. MVVM)
* Use of Combine framework
* Include loading indicators during API calls.

## Running the project
1. It's necessary to have [Xcodegen](https://github.com/yonaskolb/XcodeGen) installed to generate the project
2. At the rood folder, run `xcodegen` and open the generated `WeatherApp.xcodeproj`

Alternatively, just run `make`
