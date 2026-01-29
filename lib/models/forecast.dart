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

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final diff = itemDate.difference(todayDate).inDays;

    String dayName;
    if (diff == 0) {
      dayName = 'Hôm nay';
    } else if (diff == 1) {
      dayName = 'Mai';
    } else {
      const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      dayName = days[itemDate.weekday % 7];
    }

    return Forecast(
      date: dayName,
      minTemp: (main['temp_min'] as num).toDouble(),
      maxTemp: (main['temp_max'] as num).toDouble(),
      icon: weather['icon'] as String,
      rainChance:
          json['pop'] != null ? (json['pop'] as num).toDouble() * 100 : null,
    );
  }
}
