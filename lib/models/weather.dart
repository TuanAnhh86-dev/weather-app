// lib/models/weather.dart
class Weather {
  final String city;
  final double temp;
  final double feelsLike;      // thêm
  final String description;
  final int humidity;          // thêm
  final double windSpeed;      // thêm
  final int pressure;          // thêm
  final int visibility;        // thêm (meters)
  final String icon;           // thêm (tùy chọn)

  Weather({
    required this.city,
    required this.temp,
    required this.feelsLike,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'] as String? ?? 'Unknown',
      temp: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']['feels_like'] as num?)?.toDouble() ?? 0.0,
      description: (json['weather'] as List<dynamic>?)?.isNotEmpty == true
          ? json['weather'][0]['description'] as String? ?? ''
          : '',
      humidity: (json['main']['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
      pressure: (json['main']['pressure'] as num?)?.toInt() ?? 0,
      visibility: (json['visibility'] as num?)?.toInt() ?? 0,
      icon: (json['weather'] as List<dynamic>?)?.isNotEmpty == true
          ? json['weather'][0]['icon'] as String? ?? '01d'
          : '01d',
    );
  }
}