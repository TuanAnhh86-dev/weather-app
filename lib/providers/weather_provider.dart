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

  // hàm bất đồng bộ thực hiện lấy dữ liệu
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

  // tra vị trí 
  Future<void> getWeatherByLocation() async {
    isLoading = true;
    error = null;
    forecasts = [];
    notifyListeners();

    try {
      // 
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
  Future<void> refreshWeather() async {
  if (weather != null) {
    await getWeather(weather!.city);
  }
}

}
  