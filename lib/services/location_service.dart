import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<String> getCurrentCity() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Vui lòng bật GPS');
    }

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

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      throw Exception('Không xác định được vị trí');
    }

    final p = placemarks.first;

    
    print('Placemark: '
        '${p.name}, ${p.locality}, ${p.subAdministrativeArea}, ${p.administrativeArea}');

 
    final city = p.subAdministrativeArea ?? p.locality ?? p.administrativeArea;

    if (city == null || city.isEmpty) {
      throw Exception('Không xác định được thành phố');
    }

    return city;
  }
}
// kiểm tra GPS, kiểm tra quyền, lấy tọa độ, lấy placemark qua lat lon, trích xuất tên thành phố