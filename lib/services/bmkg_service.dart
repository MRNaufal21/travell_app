import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WeatherData {
  final String location;
  final String weather;
  final String temperature;
  final String humidity;
  final String windSpeed;
  final DateTime timestamp;

  WeatherData({
    required this.location,
    required this.weather,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.timestamp,
  });
}

class BmkgService {
  static const String apiUrl = 'https://data.bmkg.go.id/DataMKG/MEWS/DigitalForecast/DigitalForecast-Indonesia.xml';
  
  Future<WeatherData?> getWeatherForCity(String cityName) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        return _parseMockWeatherData(cityName);
      } else {
        debugPrint('BMKG API error: ${response.statusCode}');
        return _parseMockWeatherData(cityName);
      }
    } catch (e) {
      debugPrint('Error fetching weather: $e');
      return _parseMockWeatherData(cityName);
    }
  }

  WeatherData _parseMockWeatherData(String cityName) {
    final weatherConditions = ['Cerah', 'Berawan', 'Hujan Ringan', 'Cerah Berawan'];
    final temps = ['28°C', '30°C', '26°C', '29°C', '27°C'];
    final humidity = ['70%', '75%', '80%', '65%', '72%'];
    final wind = ['10 km/h', '15 km/h', '8 km/h', '12 km/h', '20 km/h'];
    
    final random = cityName.hashCode % 4;
    
    return WeatherData(
      location: cityName,
      weather: weatherConditions[random],
      temperature: temps[random],
      humidity: humidity[random],
      windSpeed: wind[random],
      timestamp: DateTime.now(),
    );
  }

  Future<List<WeatherData>> getWeatherForMultipleCities(List<String> cities) async {
    final results = <WeatherData>[];
    for (final city in cities) {
      final weather = await getWeatherForCity(city);
      if (weather != null) {
        results.add(weather);
      }
    }
    return results;
  }
}
