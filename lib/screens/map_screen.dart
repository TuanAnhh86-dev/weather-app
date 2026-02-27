import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import '../models/weather.dart';
import '../services/favorite_city_service.dart';
import '../utils/weather_type.dart';
import '../widgets/weather_overlays.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  Weather? _selectedWeather;
  LatLng? _selectedLocation;
  bool _isLoadingWeather = false;
  bool _isSatelliteView = true; // Mặc định dùng satellite view
  List<CityMarker> _cityMarkers = [];
  late AnimationController _panelController;
  late Animation<Offset> _panelAnimation;
  
  final List<Map<String, dynamic>> _vietnamCities = [
    {'name': 'Hanoi', 'lat': 21.0285, 'lon': 105.8542, 'icon': '🏛️'},
    {'name': 'Ho Chi Minh', 'lat': 10.8231, 'lon': 106.6297, 'icon': '🌆'},
    {'name': 'Da Nang', 'lat': 16.0544, 'lon': 108.2022, 'icon': '🌉'},
    {'name': 'Can Tho', 'lat': 10.0452, 'lon': 105.7469, 'icon': '🚤'},
    {'name': 'Hue', 'lat': 16.4637, 'lon': 107.5909, 'icon': '🏰'},
    {'name': 'Nha Trang', 'lat': 12.2388, 'lon': 109.1967, 'icon': '🏖️'},
    {'name': 'Vung Tau', 'lat': 10.3460, 'lon': 107.0843, 'icon': '⛱️'},
  ];

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _panelAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeInOut,
    ));
    _loadCityWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  Future<void> _loadCityWeather() async {
    final provider = context.read<WeatherProvider>();
    List<CityMarker> markers = [];

    for (var city in _vietnamCities) {
      try {
        final weather = await provider.service.fetchWeather(city['name'] as String);
        markers.add(CityMarker(
          cityName: weather.city,
          position: LatLng(city['lat'] as double, city['lon'] as double),
          weather: weather,
          icon: city['icon'] as String,
        ));
      } catch (e) {
        // Bỏ qua
      }
    }

    if (mounted) {
      setState(() => _cityMarkers = markers);
    }
  }

  Future<void> _searchCity(String cityName) async {
    if (cityName.trim().isEmpty) return;
    
    setState(() => _isLoadingWeather = true);
    
    try {
      final provider = context.read<WeatherProvider>();
      final weather = await provider.service.fetchWeather(cityName);
      
      if (mounted) {
        // Tìm vị trí thành phố trong danh sách
        final cityData = _vietnamCities.firstWhere(
          (city) => city['name'].toString().toLowerCase() == cityName.toLowerCase(),
          orElse: () => {'lat': 16.0, 'lon': 108.0},
        );
        
        final position = LatLng(cityData['lat'] as double, cityData['lon'] as double);
        _mapController.move(position, 10.0);
        
        setState(() {
          _selectedWeather = weather;
          _selectedLocation = position;
          _isLoadingWeather = false;
        });
        _panelController.forward();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWeather = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tìm thấy thành phố'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getWeatherAtLocation(LatLng position) async {
    setState(() {
      _isLoadingWeather = true;
      _selectedLocation = position;
    });

    try {
      final provider = context.read<WeatherProvider>();
      final weather = await provider.service.fetchWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _selectedWeather = weather;
          _isLoadingWeather = false;
        });
        _panelController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWeather = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể lấy thông tin thời tiết')),
        );
      }
    }
  }

  void _closePanel() {
    _panelController.reverse();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _selectedWeather = null;
          _selectedLocation = null;
        });
      }
    });
  }

  Widget _buildWeatherOverlayForCity(CityMarker cityMarker) {
    final weatherType = getWeatherType(cityMarker.weather.icon);
    
    // Tính toán vị trí pixel từ lat/lng
    final point = _mapController.camera.latLngToScreenPoint(cityMarker.position);
    final zoom = _mapController.camera.zoom;
    
    // Kích thước vùng hiệu ứng phụ thuộc vào zoom level
    final size = 150.0 * (zoom / 6.0).clamp(0.5, 3.0);
    
    Widget? overlay;
    
    switch (weatherType) {
      case WeatherType.rainLight:
        overlay = const RainOverlay(isHeavy: false, intensity: 0.6);
        break;
      case WeatherType.rainHeavy:
        overlay = const RainOverlay(isHeavy: true, intensity: 0.9);
        break;
      case WeatherType.thunder:
        overlay = const Stack(
          children: [
            RainOverlay(isHeavy: true, intensity: 1.0),
            ThunderOverlay(),
          ],
        );
        break;
      case WeatherType.snow:
        overlay = const SnowOverlay(intensity: 0.8);
        break;
      case WeatherType.cloudyDay:
      case WeatherType.cloudyNight:
        overlay = CloudOverlay(
          isDark: weatherType == WeatherType.cloudyNight,
        );
        break;
      case WeatherType.fog:
        overlay = const FogOverlay();
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Positioned(
      left: point.x - size / 2,
      top: point.y - size / 2,
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: overlay,
        ),
      ),
    );
  }
  
  Widget _buildWeatherOverlays() {
    return Stack(
      children: _cityMarkers.map((marker) {
        return _buildWeatherOverlayForCity(marker);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Bản đồ
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(16.0, 108.0),
              initialZoom: 6.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              onTap: (_, point) => _getWeatherAtLocation(point),
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatelliteView
                    ? 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}'
                    : 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.example.weather_app',
                subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
              ),
              MarkerLayer(
                markers: _cityMarkers.map((cityMarker) {
                  return Marker(
                    width: 100.0,
                    height: 100.0,
                    point: cityMarker.position,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedWeather = cityMarker.weather;
                          _selectedLocation = cityMarker.position;
                        });
                        _panelController.forward();
                        _mapController.move(cityMarker.position, 10.0);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getTemperatureGradient(cityMarker.weather.temp),
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cityMarker.icon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${cityMarker.weather.temp.round()}°',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        offset: const Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.location_pin,
                            color: Colors.red.shade600,
                            size: 32,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 50.0,
                      height: 50.0,
                      point: _selectedLocation!,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.shade500.withValues(alpha: 0.3),
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Colors.blue.shade700,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Hiệu ứng thời tiết trên bản đồ
          if (_cityMarkers.isNotEmpty)
            IgnorePointer(
              child: _buildWeatherOverlays(),
            ),

          // Top bar với search
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search bar
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm thành phố...',
                          hintStyle: GoogleFonts.roboto(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        onChanged: (value) => setState(() {}),
                        onSubmitted: _searchCity,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Location button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.blue),
                      onPressed: () {
                        _mapController.move(LatLng(16.0, 108.0), 6.0);
                      },
                      tooltip: 'Về Việt Nam',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Zoom controls
          Positioned(
            right: 16,
            bottom: _selectedWeather != null ? 260 : 100,
            child: Column(
              children: [
                _ZoomButton(
                  icon: Icons.add,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                  },
                ),
                const SizedBox(height: 8),
                _ZoomButton(
                  icon: Icons.remove,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                  },
                ),
                const SizedBox(height: 8),
                _ZoomButton(
                  icon: _isSatelliteView ? Icons.map : Icons.satellite,
                  onPressed: () {
                    setState(() {
                      _isSatelliteView = !_isSatelliteView;
                    });
                  },
                  tooltip: _isSatelliteView ? 'Bản đồ' : 'Vệ tinh',
                ),
              ],
            ),
          ),

          // Weather panel
          if (_selectedWeather != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _panelAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedWeather!.city,
                                        style: GoogleFonts.roboto(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedWeather!.description,
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.network(
                                  'https://openweathermap.org/img/wn/${_selectedWeather!.icon}@2x.png',
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.cloud, size: 60);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Temperature
                            Row(
                              children: [
                                Text(
                                  '${_selectedWeather!.temp.round()}°',
                                  style: GoogleFonts.roboto(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w200,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cảm giác',
                                      style: GoogleFonts.roboto(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      '${_selectedWeather!.feelsLike.round()}°C',
                                      style: GoogleFonts.roboto(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Details grid
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _DetailItem(
                                          icon: Icons.water_drop_outlined,
                                          label: 'Độ ẩm',
                                          value: '${_selectedWeather!.humidity}%',
                                        ),
                                      ),
                                      Expanded(
                                        child: _DetailItem(
                                          icon: Icons.air,
                                          label: 'Gió',
                                          value: '${_selectedWeather!.windSpeed.toStringAsFixed(1)} m/s',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _DetailItem(
                                          icon: Icons.speed,
                                          label: 'Áp suất',
                                          value: '${_selectedWeather!.pressure} hPa',
                                        ),
                                      ),
                                      Expanded(
                                        child: _DetailItem(
                                          icon: Icons.visibility_outlined,
                                          label: 'Tầm nhìn',
                                          value: '${(_selectedWeather!.visibility / 1000).toStringAsFixed(1)} km',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Close button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _closePanel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Đóng',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading
          if (_isLoadingWeather)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Color> _getTemperatureGradient(double temp) {
    if (temp < 15) {
      return [Colors.blue.shade400, Colors.blue.shade600];
    } else if (temp < 25) {
      return [Colors.green.shade400, Colors.green.shade600];
    } else if (temp < 30) {
      return [Colors.orange.shade400, Colors.orange.shade600];
    } else {
      return [Colors.red.shade400, Colors.red.shade600];
    }
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const _ZoomButton({
    required this.icon, 
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        iconSize: 24,
        tooltip: tooltip,
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blue.shade700),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CityMarker {
  final String cityName;
  final LatLng position;
  final Weather weather;
  final String icon;

  CityMarker({
    required this.cityName,
    required this.position,
    required this.weather,
    required this.icon,
  });
}
