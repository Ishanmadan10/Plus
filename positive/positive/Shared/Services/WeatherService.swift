import Foundation
import CoreLocation

@MainActor
class WeatherService: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var temperature: Int?
    @Published var conditionNow: String = ""
    @Published var conditionTonight: String = ""
    @Published var cityName: String = ""
    @Published var isLoading: Bool = true

    private let locationManager = CLLocationManager()
    private var location: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
            default:
                // Fallback to Bangalore if denied
                await fetchWeather(lat: 12.9716, lon: 77.5946)
                await reverseGeocode(lat: 12.9716, lon: 77.5946)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        Task { @MainActor in
            self.location = loc
            let lat = loc.coordinate.latitude
            let lon = loc.coordinate.longitude
            await fetchWeather(lat: lat, lon: lon)
            await reverseGeocode(lat: lat, lon: lon)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            await fetchWeather(lat: 12.9716, lon: 77.5946)
            await reverseGeocode(lat: 12.9716, lon: 77.5946)
        }
    }

    // MARK: - Fetch Weather

    private func fetchWeather(lat: Double, lon: Double) async {
        let urlString = """
        https://api.open-meteo.com/v1/forecast?\
        latitude=\(lat)&longitude=\(lon)\
        &current=temperature_2m,weathercode\
        &hourly=precipitation_probability,weathercode\
        &timezone=auto&forecast_days=1
        """

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)

            self.temperature = Int(decoded.current.temperature_2m.rounded())
            self.conditionNow = weatherDescription(for: decoded.current.weathercode)
            self.conditionTonight = tonightForecast(from: decoded.hourly)
            self.isLoading = false
        } catch {
            self.conditionNow = "Weather unavailable"
            self.isLoading = false
        }
    }

    // MARK: - Reverse Geocode

    private func reverseGeocode(lat: Double, lon: Double) async {
        let geocoder = CLGeocoder()
        let loc = CLLocation(latitude: lat, longitude: lon)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(loc)
            self.cityName = placemarks.first?.locality
                ?? placemarks.first?.administrativeArea
                ?? "Your City"
        } catch {
            self.cityName = "Your City"
        }
    }

    // MARK: - WMO Weather Code → Description

    private func weatherDescription(for code: Int) -> String {
        switch code {
        case 0:           return "Clear skies"
        case 1:           return "Mostly clear"
        case 2:           return "Partly cloudy"
        case 3:           return "Overcast"
        case 45, 48:      return "Foggy"
        case 51, 53, 55:  return "Drizzling"
        case 61:          return "Light rain"
        case 63:          return "Moderate rain"
        case 65:          return "Heavy rain"
        case 71, 73, 75:  return "Snowing"
        case 80, 81:      return "Rain showers"
        case 82:          return "Heavy showers"
        case 95:          return "Thunderstorms"
        case 96, 99:      return "Stormy"
        default:          return "Cloudy"
        }
    }

    // MARK: - Tonight Forecast from Hourly Data

    private func tonightForecast(from hourly: OpenMeteoHourly) -> String {
        // Evening hours: index 18–23 (6 PM – midnight)
        let eveningIndices = Array(18..<min(24, hourly.precipitation_probability.count))

        guard !eveningIndices.isEmpty else { return "Clear tonight" }

        let maxRainChance = eveningIndices
            .map { hourly.precipitation_probability[$0] }
            .max() ?? 0

        let eveningCode = eveningIndices
            .map { hourly.weathercode[$0] }
            .max() ?? 0

        switch maxRainChance {
        case 0..<20:
            return eveningCode == 0 ? "Clear skies tonight" : "Mostly clear tonight"
        case 20..<50:
            return "Possible showers tonight"
        case 50..<75:
            return "Rain likely tonight"
        default:
            return eveningCode >= 95 ? "Storms tonight" : "Heavy rain tonight"
        }
    }
}

// MARK: - Decodable Models

struct OpenMeteoResponse: Decodable {
    let current: CurrentWeather
    let hourly: OpenMeteoHourly
}

struct CurrentWeather: Decodable {
    let temperature_2m: Double
    let weathercode: Int
}

struct OpenMeteoHourly: Decodable {
    let precipitation_probability: [Int]
    let weathercode: [Int]
}
