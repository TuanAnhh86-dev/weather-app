import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService service;

  WeatherProvider(this.service);

  Weather? weather;
  List<Forecast> forecasts = [];
  bool isLoading = false;
  String? error;

  // ===== SEARCH BY CITY =====
  Future<void> getWeather(String city) async {
    isLoading = true;
    error = null;
    forecasts = [];
    notifyListeners();

    try {
      weather = await service.fetchWeather(city);
      forecasts = await service.fetchForecast(city);
    } catch (e) {
      error = 'Không tìm thấy thành phố hoặc lỗi mạng';
      weather = null;
      forecasts = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // ===== SEARCH BY GPS → CITY =====
  Future<void> getWeatherByLocation() async {
    isLoading = true;
    error = null;
    forecasts = [];
    notifyListeners();

    try {
      // ✅ CHỈ LẤY TÊN THÀNH PHỐ
      final city = await LocationService.getCurrentCity();

      weather = await service.fetchWeather(city);
      forecasts = await service.fetchForecast(city);
    } catch (e) {
      error = 'Không lấy được thành phố từ vị trí';
      weather = null;
      forecasts = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
