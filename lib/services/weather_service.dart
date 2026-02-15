import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';
import '../utils/string_utils.dart';
import '../utils/vietnam_city_map.dart';

class WeatherService {
  final String apiKey;
  WeatherService(this.apiKey);

  // ================= CURRENT WEATHER (CITY) =================
  Future<Weather> fetchWeather(String city) async {
    final normalizedCity =
        StringUtils.removeVietnameseDiacritics(city.trim());

    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'q': normalizedCity,
        'appid': apiKey,
        'units': 'metric',
        'lang': 'vi',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // 🔥 Chuẩn hoá tên thành phố trả về
      data['name'] = VietnamCityMap.getDisplayName(data['name']);

      return Weather.fromJson(data);
    } else {
      throw Exception('City not found');
    }
  }

  // ================= FORECAST (CITY) =================
  Future<List<Forecast>> fetchForecast(String city) async {
    final normalizedCity =
        StringUtils.removeVietnameseDiacritics(city.trim());

    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/forecast',
      {
        'q': normalizedCity,
        'appid': apiKey,
        'units': 'metric',
        'lang': 'vi',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Forecast not found');
    }

    return _parseForecast(json.decode(response.body));
  }

  // ================= FORECAST (LAT LON) =================
  Future<List<Forecast>> fetchForecastByLocation(
      double lat, double lon) async {

    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/forecast',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': apiKey,
        'units': 'metric',
        'lang': 'vi',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Location forecast failed');
    }

    return _parseForecast(json.decode(response.body));
  }

  // ================= CURRENT WEATHER (LAT LON) =================
  Future<Weather> fetchWeatherByLocation(
      double lat, double lon) async {

    final uri = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': apiKey,
        'units': 'metric',
        'lang': 'vi',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // 🔥 Chuẩn hoá tên thành phố trả về
      data['name'] = VietnamCityMap.getDisplayName(data['name']);

      return Weather.fromJson(data);
    } else {
      throw Exception('Location weather failed');
    }
  }

  // ================= PARSE FORECAST =================
  List<Forecast> _parseForecast(Map<String, dynamic> data) {
    final List list = data['list'];
    final Map<DateTime, List<Map<String, dynamic>>> dailyMap = {};

    for (final item in list) {
      final dt = DateTime.parse(item['dt_txt']);
      final dateKey = DateTime(dt.year, dt.month, dt.day);

      final today = DateTime.now();
      final todayKey = DateTime(today.year, today.month, today.day);

      if (dateKey.isBefore(todayKey)) continue;

      dailyMap.putIfAbsent(dateKey, () => []);
      dailyMap[dateKey]!.add(item);
    }

    final sortedDates = dailyMap.keys.toList()..sort();
    final now = DateTime.now();
    final List<Forecast> forecasts = [];

    for (int i = 0; i < sortedDates.length && i < 4; i++) {
      final date = sortedDates[i];
      final dayData = dailyMap[date]!;

      double minTemp = double.infinity;
      double maxTemp = -double.infinity;
      double maxPop = 0;
      Map<String, dynamic>? noonData;

      for (final item in dayData) {
        final main = item['main'];

        minTemp = minTemp < (main['temp_min'] as num).toDouble()
            ? minTemp
            : (main['temp_min'] as num).toDouble();

        maxTemp = maxTemp > (main['temp_max'] as num).toDouble()
            ? maxTemp
            : (main['temp_max'] as num).toDouble();

        final pop = (item['pop'] as num?)?.toDouble() ?? 0;
        if (pop > maxPop) maxPop = pop;

        final dt = DateTime.parse(item['dt_txt']);
        if (dt.hour == 12) noonData = item;
      }

      final diff =
          date.difference(DateTime(now.year, now.month, now.day)).inDays;

      final dayName = diff == 0
          ? 'Hôm nay'
          : diff == 1
              ? 'Mai'
              : ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][date.weekday % 7];

      forecasts.add(
        Forecast(
          date: dayName,
          minTemp: minTemp,
          maxTemp: maxTemp,
          icon: noonData?['weather'][0]['icon'] ??
              dayData.first['weather'][0]['icon'],
          rainChance: maxPop > 0 ? maxPop * 100 : null,
        ),
      );
    }

    return forecasts;
  }
}
