// lib/utils/vietnam_city_map.dart
class VietnamCityMap {
  static const Map<String, String> noDiacriticsToWithDiacritics = {
    'ho chi minh': 'TP. Hồ Chí Minh',
    'ho chi minh city': 'TP. Hồ Chí Minh',
    'saigon': 'TP. Hồ Chí Minh',
    'ha noi': 'Hà Nội',
    'hanoi': 'Hà Nội',
    'haiphong': 'Hải Phòng',
    'hai phong': 'Hải Phòng',
    'da nang': 'Đà Nẵng',
    'danang': 'Đà Nẵng',
    'can tho': 'Cần Thơ',
    'cantho': 'Cần Thơ',
    'hue': 'Huế',
    'thua thien hue': 'Huế',
    'nha trang': 'Nha Trang',
    'khanh hoa': 'Nha Trang',
    'vung tau': 'Vũng Tàu',
    'ba ria vung tau': 'Vũng Tàu',
    'bien hoa': 'Biên Hòa',
    'dong nai': 'Đồng Nai',
    'thai nguyen': 'Thái Nguyên',
    // ... thêm đầy đủ 63 tỉnh/thành phố (copy danh sách dưới)
    // Bạn có thể tìm danh sách đầy đủ trên Wikipedia hoặc trang chính thức
  };

  static String getDisplayName(String apiName) {
    final key = apiName.toLowerCase().trim();
    return noDiacriticsToWithDiacritics[key] ?? apiName; // Nếu không tìm thấy, giữ nguyên
  }
}