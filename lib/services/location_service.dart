import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<String> getCurrentCity() async {
    // 1. Kiểm tra GPS
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Vui lòng bật GPS');
    }

    // 2. Quyền vị trí
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

    // 3. Lấy tọa độ (đủ cho cấp thành phố)
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    // 4. Reverse geocoding
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      throw Exception('Không xác định được vị trí');
    }

    final placemark = placemarks.first;

    // ⭐ CHỈ LẤY THÀNH PHỐ (ƯU TIÊN administrativeArea)
    final city = placemark.administrativeArea;

    if (city == null || city.isEmpty) {
      throw Exception('Không xác định được thành phố');
    }

    return city;
  }
}
