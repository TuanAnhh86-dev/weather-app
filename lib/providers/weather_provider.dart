import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../models/forecast.dart'; // import model Forecast
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService service;

  WeatherProvider(this.service);

  Weather? weather;
  List<Forecast> forecasts = []; // ← THÊM DÒNG NÀY
  bool isLoading = false;
  String? error;

  Future<void> getWeather(String city) async {
    isLoading = true;
    error = null;
    forecasts = []; // reset dự báo cũ
    notifyListeners();

    try {
      weather = await service.fetchWeather(city);
      forecasts = await service.fetchForecast(city); // ← GỌI API dự báo
    } catch (e) {
      error = 'Không tìm thấy thành phố hoặc lỗi mạng';
      weather = null;
      forecasts = [];
    }

    isLoading = false;
    notifyListeners();
  }
}