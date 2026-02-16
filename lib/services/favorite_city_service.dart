import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCityService {
  static const String key = 'favorite_cities';

  static Future<List<String>> getCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  static Future<void> addCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = prefs.getStringList(key) ?? [];

    if (!cities.contains(city)) {
      cities.add(city);
      await prefs.setStringList(key, cities);
    }
  }

  static Future<void> removeCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final cities = prefs.getStringList('favorite_cities') ?? [];
    cities.remove(city);
    await prefs.setStringList('favorite_cities', cities);
  }
}
