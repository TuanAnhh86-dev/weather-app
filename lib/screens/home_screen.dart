import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/favorite_city_service.dart';
import 'favorite_screen.dart';
import 'map_screen.dart';
import '../providers/weather_provider.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../utils/weather_type.dart';
import '../services/search_history_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _history = [];
  bool _showHistoryList = false;
  Timer? _historyTimer;
  Future<void> _toggleFavorite(String city) async {
    final messenger = ScaffoldMessenger.of(context);

    final cities = await FavoriteCityService.getCities();

    if (!mounted) return;

    messenger.hideCurrentSnackBar();

    final isFavorite = cities.contains(city);

    if (isFavorite) {
      await FavoriteCityService.removeCity(city);
    } else {
      await FavoriteCityService.addCity(city);
    }

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? "$city đã bị xoá" : "Đã lưu $city",
        ),
        duration: Duration(seconds: isFavorite ? 5 : 3),
        behavior: SnackBarBehavior.floating,
        
            
      ),
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _historyTimer?.cancel();
  }

  // tìm kiếm thành phố
  void _searchCity(WeatherProvider provider, String value) async {
    final city = value.trim();

    if (provider.isLoading) return;

    if (city.isEmpty) {
      _showMessage('Vui lòng nhập tên thành phố');
      return;
    }

    if (city.length < 2) {
      _showMessage('Tên thành phố quá ngắn');
      return;
    }
    final validCity = RegExp(r"^[a-zA-ZÀ-ỹ\s\-]+$");
    if (!validCity.hasMatch(city)) {
      _showMessage('Tên thành phố không hợp lệ');
      return;
    }

    //query thời tiết
    await provider.getWeather(city);
    await SearchHistoryService.addCity(city);

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  //hiển thị tin nhắn báo lỗi khi tìm kiếm thành phố
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHistory() async {
    final history = await SearchHistoryService.getHistory();

    if (!mounted) return;

    setState(() {
      _history = history;
      _showHistoryList = true;
    });

    // Tự động ẩn sau 5 giây
    _historyTimer?.cancel();
    _historyTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showHistoryList = false;
        });
      }
    });
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false, // rất quan trọng
      body: Stack(
        children: [
          _buildBackground(provider.weather),
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    _buildSearch(provider),
                    const SizedBox(height: 12),
                    Expanded(
                      child: provider.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          : provider.error != null
                              ? _buildError(provider.error!)
                              : provider.weather == null
                                  ? _buildInitial()
                                  : _buildWeather(provider.weather!, provider),
                    ),
                  ],
                ),
                if (_showHistoryList && _history.isNotEmpty)
                  _buildHistoryOverlay(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryOverlay(WeatherProvider provider) {
    return Positioned(
      top: 140, // chỉnh khoảng cách ở đây
      left: 18,
      right: 18,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(18),
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final city = _history[index];
              return _buildHistoryItem(city, provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String city, WeatherProvider provider) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.white70, size: 20),
      title: Text(
        city,
        style: GoogleFonts.openSans(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, color: Colors.white54, size: 18),
        onPressed: () async {
          await SearchHistoryService.removeCity(city);

          setState(() {
            _history.remove(city); // ❗ không cần load lại toàn bộ
          });
        },
      ),
      onTap: () {
        _controller.text = city;
        _searchCity(provider, city);

        setState(() {
          _showHistoryList = false;
        });
      },
    );
  }

  Widget _buildBackground(Weather? weather) {
    if (weather == null) {
      return _gradientBg([
        const Color(0xFF4A90E2),
        const Color(0xFF2E5A9A),
      ]);
    }

    final type = getWeatherType(weather.icon);

    switch (type) {
      // ☀️ NGÀY NẮNG
      case WeatherType.sunnyDay:
        return _gradientBg([
          const Color(0xFFFFD200),
          const Color(0xFFFFA000),
          const Color(0xFF4FC3F7),
        ]);

      // 🌙 ĐÊM QUANG
      case WeatherType.sunnyNight:
        return _gradientBg([
          const Color(0xFF0F2027),
          const Color(0xFF203A43),
          const Color(0xFF2C5364),
        ]);

      // ☁️ NGÀY NHIỀU MÂY
      case WeatherType.cloudyDay:
        return _gradientBg([
          const Color(0xFFBBD2C5),
          const Color(0xFF536976),
        ]);

      // ☁️🌙 ĐÊM NHIỀU MÂY
      case WeatherType.cloudyNight:
        return _gradientBg([
          const Color(0xFF232526),
          const Color(0xFF414345),
        ]);

      // 🌧️ MƯA NHẸ
      case WeatherType.rainLight:
        return _gradientBg([
          const Color(0xFF4B79A1),
          const Color(0xFF283E51),
        ]);

      // 🌧️🌧️ MƯA LỚN
      case WeatherType.rainHeavy:
        return _gradientBg([
          const Color(0xFF0F2027),
          const Color(0xFF000000),
        ]);

      // ⛈️ SẤM SÉT
      case WeatherType.thunder:
        return _gradientBg([
          const Color(0xFF000000),
          const Color(0xFF232526),
          const Color(0xFF414345),
        ]);

      // ❄️ TUYẾT
      case WeatherType.snow:
        return _gradientBg([
          const Color(0xFFFDFBFB),
          const Color(0xFFE2EBF0),
        ]);

      // 🌫️ SƯƠNG MÙ
      case WeatherType.fog:
        return _gradientBg([
          const Color(0xFF757F9A),
          const Color(0xFFD7DDE8),
        ]);
    }
  }

  Widget _gradientBg(List<Color> colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
    );
  }

  // ================= UI PARTS =================
  Widget _buildHeader() {
    final provider = context.read<WeatherProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () async {
              final String? selectedCity = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoriteScreen(),
                ),
              );

              if (selectedCity != null) {
                provider.getWeather(selectedCity);
              }
            },
          ),

          /// TAP ĐỂ REFRESH
          GestureDetector(
            onTap: () {
              provider.refreshWeather();
            },
            child: Text(
              'Forecast Weather',
              style: GoogleFonts.openSans(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MapScreen(),
                ),
              );
            },
            tooltip: 'Bản đồ thời tiết',
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(WeatherProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: GoogleFonts.openSans(color: Colors.white),
              onTap: _showHistory,
              onChanged: (value) async {
                final history = await SearchHistoryService.getHistory();

                setState(() {
                  _history = history
                      .where((city) =>
                          city.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                  _showHistoryList = true;
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thành phố',
                hintStyle: GoogleFonts.openSans(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.black.withOpacity(0.25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (v) {
                _searchCity(provider, v);
                setState(() {
                  _showHistoryList = false;
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: provider.isLoading
                ? null
                : () => provider.getWeatherByLocation(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitial() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_outlined,
            size: 120, color: Colors.black.withOpacity(0.25)),
        const SizedBox(height: 16),
        Text(
          'Nhập tên thành phố để xem thời tiết',
          style: GoogleFonts.openSans(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ================= WEATHER =================
  Widget _buildWeather(Weather w, WeatherProvider provider) {
    final isSmall = MediaQuery.of(context).size.width < 360;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      child: Column(
        children: [
          Text(
            w.city,
            style: GoogleFonts.openSans(
              fontSize: isSmall ? 30 : 38,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.star, color: Colors.yellow),
            onPressed: () {
              _toggleFavorite(w.city);
            },
          ),

          /// NHIỆT ĐỘ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                w.temp.round().toString(),
                style: GoogleFonts.openSans(
                  fontSize: isSmall ? 78 : 96,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '°C',
                  style: GoogleFonts.openSans(
                    fontSize: isSmall ? 22 : 26,
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Nhiệt độ cảm nhận ${w.feelsLike.round()}°C',
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            w.description.isNotEmpty
                ? '${w.description[0].toUpperCase()}${w.description.substring(1)}'
                : 'Không có mô tả',
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.85),
            ),
          ),

          const SizedBox(height: 24),

          /// INFO GRID
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth < 360 ? 1.6 : 1.4,
                children: [
                  _InfoItem(Icons.water_drop, 'Độ ẩm', '${w.humidity}%'),
                  _InfoItem(Icons.air, 'Gió',
                      '${w.windSpeed.toStringAsFixed(1)} m/s'),
                  _InfoItem(Icons.visibility, 'Tầm nhìn',
                      '${(w.visibility / 1000).toStringAsFixed(1)} km'),
                  _InfoItem(Icons.compress, 'Áp suất', '${w.pressure} hPa'),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          /// FORECAST
          Text(
            'Dự báo thời tiết',
            style: GoogleFonts.openSans(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 160,
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white70),
                  )
                : provider.forecasts.isEmpty
                    ? const Center(
                        child: Text(
                          'Không có dữ liệu dự báo',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.forecasts.length,
                        itemBuilder: (context, index) {
                          final f = provider.forecasts[index];
                          return _ForecastCard(
                            day: f.date,
                            temp: '${f.minTemp.round()} ~ ${f.maxTemp.round()}',
                            icon: _mapIcon(f.icon),
                            rain: f.rainChance != null
                                ? '${f.rainChance!.round()}%'
                                : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  IconData _mapIcon(String icon) {
    switch (icon) {
      case '01d':
        return Icons.wb_sunny;
      case '01n':
        return Icons.nights_stay;

      case '02d':
      case '02n':
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return Icons.cloud;

      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return Icons.grain;

      case '11d':
      case '11n':
        return Icons.thunderstorm;

      case '13d':
      case '13n':
        return Icons.ac_unit;

      case '50d':
      case '50n':
        return Icons.blur_on;

      default:
        return Icons.cloud;
    }
  }
}

// ================= INFO ITEM =================
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: Colors.white70),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.openSans(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

// ================= FORECAST CARD =================
class _ForecastCard extends StatelessWidget {
  final String day;
  final String temp;
  final IconData icon;
  final String? rain;

  const _ForecastCard({
    required this.day,
    required this.temp,
    required this.icon,
    this.rain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day,
              style: GoogleFonts.openSans(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 6),
          Icon(icon, size: 34, color: Colors.white),
          const SizedBox(height: 6),
          Text(temp,
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.white)),
          if (rain != null)
            Text('Mưa $rain',
                style:
                    GoogleFonts.openSans(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}
