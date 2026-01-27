class Forecast {
  final String date; // "Hôm nay", "Mai", "Th 3",...
  final double minTemp;
  final double maxTemp;
  final String icon;
  final double? rainChance;

  Forecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
    this.rainChance,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final weather = json['weather'][0];
    final dtTxt = json['dt_txt'] as String;
    final dateTime = DateTime.parse(dtTxt);
    
    final now = DateTime.now();
    String dayName;
    final diff = dateTime.difference(now).inDays;

    if (diff == 0) dayName = 'Hôm nay';
    else if (diff == 1) dayName = 'Mai';
    else dayName = 'Th ${dateTime.weekday + 1}';

    return Forecast(
      date: dayName,
      minTemp: (main['temp_min'] as num).toDouble(),
      maxTemp: (main['temp_max'] as num).toDouble(),
      icon: weather['icon'] as String,
      rainChance: json['pop'] != null ? (json['pop'] as num).toDouble() * 100 : null,
    );
  }
}