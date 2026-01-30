enum WeatherType {
  sunnyDay,
  sunnyNight,

  cloudyDay,
  cloudyNight,

  rainLight,
  rainHeavy,

  thunder,

  snow,

  fog,
}
WeatherType getWeatherType(String icon) {
  final isDay = icon.endsWith('d');

  // ☀️ Trời quang
  if (icon.startsWith('01')) {
    return isDay ? WeatherType.sunnyDay : WeatherType.sunnyNight;
  }

  // ☁️ Có mây
  if (icon.startsWith('02') ||
      icon.startsWith('03') ||
      icon.startsWith('04')) {
    return isDay ? WeatherType.cloudyDay : WeatherType.cloudyNight;
  }

  // 🌧️ Mưa
  if (icon.startsWith('09')) {
    return WeatherType.rainHeavy; // mưa rào
  }

  if (icon.startsWith('10')) {
    return WeatherType.rainLight; // mưa thường
  }

  // ⛈️ Sấm sét
  if (icon.startsWith('11')) {
    return WeatherType.thunder;
  }

  // ❄️ Tuyết
  if (icon.startsWith('13')) {
    return WeatherType.snow;
  }

  // 🌫️ Sương mù
  if (icon.startsWith('50')) {
    return WeatherType.fog;
  }

  // fallback
  return isDay ? WeatherType.cloudyDay : WeatherType.cloudyNight;
}
