import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/vietnam_city_map.dart';

class LocationService {
  static Future<String> getCurrentCity() async {
    try {
      // 1️⃣ Kiểm tra GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Vui lòng bật GPS');
      }

      // 2️⃣ Kiểm tra quyền
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          throw Exception('Quyền vị trí bị từ chối');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền vị trí bị từ chối vĩnh viễn');
      }

      // 3️⃣ Lấy vị trí hiện tại (chỉ lấy 1 lần)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // 4️⃣ Lấy thông tin địa chỉ từ tọa độ
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception('Không xác định được vị trí');
      }

      final p = placemarks.first;

      print(
        'Placemark: ${p.name}, ${p.locality}, '
        '${p.subAdministrativeArea}, ${p.administrativeArea}',
      );

      // 5️⃣ Ưu tiên administrativeArea cho Việt Nam
      String? city = p.administrativeArea;

      // Fallback nếu administrativeArea null
      city ??= p.locality;
      city ??= p.subAdministrativeArea;

      if (city == null || city.isEmpty) {
        throw Exception('Không xác định được thành phố');
      }

      // 6️⃣ Chuẩn hóa tên theo map
      final displayCity = VietnamCityMap.getDisplayName(city);

      return displayCity;
    } catch (e) {
      print("Location error: $e");
      rethrow;
    }
  }
}
