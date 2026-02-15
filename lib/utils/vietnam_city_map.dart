// lib/utils/vietnam_city_map.dart
class VietnamCityMap {
  static const Map<String, String> noDiacriticsToWithDiacritics = {
    // ===== 5 TP trực thuộc TW =====
    'ho chi minh': 'TP. Hồ Chí Minh',
    'ho chi minh city': 'TP. Hồ Chí Minh',
    'saigon': 'TP. Hồ Chí Minh',

    'ha noi': 'Hà Nội',
    'hanoi': 'Hà Nội',

    'hai phong': 'Hải Phòng',
    'haiphong': 'Hải Phòng',

    'da nang': 'Đà Nẵng',
    'danang': 'Đà Nẵng',

    'can tho': 'Cần Thơ',
    'cantho': 'Cần Thơ',

    // ===== Các tỉnh =====
    'an giang': 'An Giang',
    'ba ria vung tau': 'Bà Rịa - Vũng Tàu',
    'vung tau': 'Bà Rịa - Vũng Tàu',
    'bac giang': 'Bắc Giang',
    'bac kan': 'Bắc Kạn',
    'bac ninh': 'Bắc Ninh',
    'ben tre': 'Bến Tre',
    'binh dinh': 'Bình Định',
    'binh duong': 'Bình Dương',
    'binh phuoc': 'Bình Phước',
    'binh thuan': 'Bình Thuận',
    'bac lieu': 'Bạc Liêu',
    'ca mau': 'Cà Mau',
    'cao bang': 'Cao Bằng',
    'dak lak': 'Đắk Lắk',
    'dak nong': 'Đắk Nông',
    'dien bien': 'Điện Biên',
    'dong nai': 'Đồng Nai',
    'dong thap': 'Đồng Tháp',
    'gia lai': 'Gia Lai',
    'ha giang': 'Hà Giang',
    'ha nam': 'Hà Nam',
    'ha tinh': 'Hà Tĩnh',
    'hai duong': 'Hải Dương',
    'hau giang': 'Hậu Giang',
    'hoa binh': 'Hòa Bình',
    'hung yen': 'Hưng Yên',
    'khanh hoa': 'Khánh Hòa',
    'kien giang': 'Kiên Giang',
    'kon tum': 'Kon Tum',
    'lai chau': 'Lai Châu',
    'lam dong': 'Lâm Đồng',
    'lang son': 'Lạng Sơn',
    'lao cai': 'Lào Cai',
    'long an': 'Long An',
    'nam dinh': 'Nam Định',
    'nghe an': 'Nghệ An',
    'ninh binh': 'Ninh Bình',
    'ninh thuan': 'Ninh Thuận',
    'phu tho': 'Phú Thọ',
    'phu yen': 'Phú Yên',
    'quang binh': 'Quảng Bình',
    'quang nam': 'Quảng Nam',
    'quang ngai': 'Quảng Ngãi',
    'quang ninh': 'Quảng Ninh',
    'quang tri': 'Quảng Trị',
    'soc trang': 'Sóc Trăng',
    'son la': 'Sơn La',
    'tay ninh': 'Tây Ninh',
    'thai binh': 'Thái Bình',
    'thai nguyen': 'Thái Nguyên',
    'thanh hoa': 'Thanh Hóa',
    'thua thien hue': 'Thừa Thiên Huế',
    'tien giang': 'Tiền Giang',
    'tra vinh': 'Trà Vinh',
    'tuyen quang': 'Tuyên Quang',
    'vinh long': 'Vĩnh Long',
    'vinh phuc': 'Vĩnh Phúc',
    'yen bai': 'Yên Bái',
  };

  static String getDisplayName(String apiName) {
    final key = apiName.toLowerCase().trim();
    return noDiacriticsToWithDiacritics[key] ?? apiName;
  }
}
