import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';

class WeatherService {
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> fetchWeather(String city) async {
    final uri = Uri.parse(
  'https://api.openweathermap.org/data/2.5/weather'
  '?q=$city&appid=$apiKey&units=metric&lang=vi',
  );  

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('City not found');
    }
  }
  Future<List<Forecast>> fetchForecast(String city) async {
  final uri = Uri.parse(
    'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=vi',
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final list = data['list'] as List<dynamic>;

    // Lấy 1 forecast mỗi ngày (ví dụ: khoảng 12h)
    final dailyForecasts = <Forecast>[];
    String? lastDate;
    for (var item in list) {
      final dtTxt = item['dt_txt'] as String;
      final datePart = dtTxt.split(' ')[0];
      if (lastDate != datePart) {
        dailyForecasts.add(Forecast.fromJson(item));
        lastDate = datePart;
      }
    }
    return dailyForecasts.take(4).toList(); // lấy 4 ngày, nếu muốn thay đổi thì ở đây
  } else {
    throw Exception('Forecast not found');
  }
}
}
