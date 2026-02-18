import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _key = 'search_history';

  /// Lấy danh sách lịch sử
  static Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Thêm thành phố
  static Future<void> addCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];

    // Xoá nếu đã tồn tại (để tránh trùng)
    history.remove(city);

    // Thêm lên đầu danh sách
    history.insert(0, city);

    // Giới hạn tối đa 10 item
    if (history.length > 10) {
      history.removeLast();
    }

    await prefs.setStringList(_key, history);
  }

  /// Xoá 1 thành phố
  static Future<void> removeCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_key) ?? [];

    history.remove(city);

    await prefs.setStringList(_key, history);
  }

  /// Xoá toàn bộ
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
