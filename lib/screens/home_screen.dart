import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/weather_provider.dart';
import '../models/weather.dart';
import '../models/forecast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= SEARCH =================
  void _searchCity(WeatherProvider provider, String value) {
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

    provider.getWeather(city);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.openSans()),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF2E5A9A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearch(provider),
              const SizedBox(height: 12),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : provider.error != null
                        ? _buildError(provider.error!)
                        : provider.weather == null
                            ? _buildInitial()
                            : _buildWeather(provider.weather!, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI PARTS =================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Forecast Weather',
            style: GoogleFonts.openSans(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(WeatherProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        controller: _controller,
        style: GoogleFonts.openSans(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm thành phố',
          hintStyle: GoogleFonts.openSans(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (v) => _searchCity(provider, v),
      ),
    );
  }

  Widget _buildInitial() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_outlined,
            size: 120, color: Colors.white.withOpacity(0.7)),
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
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Cảm giác ${w.feelsLike.round()}°C',
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            w.description.isNotEmpty
                ? '${w.description[0].toUpperCase()}${w.description.substring(1)}'
                : '',
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.85),
            ),
          ),

          const SizedBox(height: 24),

          /// INFO GRID
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isSmall ? 1.35 : 1.15,
            children: [
              _InfoItem(Icons.water_drop, 'Độ ẩm', '${w.humidity}%'),
              _InfoItem(Icons.air, 'Gió',
                  '${w.windSpeed.toStringAsFixed(1)} m/s'),
              _InfoItem(Icons.visibility, 'Tầm nhìn',
                  '${(w.visibility / 1000).toStringAsFixed(1)} km'),
              _InfoItem(Icons.compress, 'Áp suất', '${w.pressure} hPa'),
            ],
          ),

          const SizedBox(height: 28),

          /// FORECAST
          Text(
            'Dự báo 7 ngày',
            style: GoogleFonts.openSans(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 160,
            child: provider.forecasts.isEmpty
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Colors.white70),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.forecasts.length,
                    itemBuilder: (context, index) {
                      final f = provider.forecasts[index];
                      return _ForecastCard(
                        day: f.date,
                        temp:
                            '${f.minTemp.round()} ~ ${f.maxTemp.round()}',
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
      case '01n':
        return Icons.wb_sunny;
      case '09d':
      case '10d':
        return Icons.grain;
      case '11d':
        return Icons.thunderstorm;
      case '13d':
        return Icons.ac_unit;
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
              style: GoogleFonts.openSans(
                  fontSize: 12, color: Colors.white70)),
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
              style: GoogleFonts.openSans(
                  fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 6),
          Icon(icon, size: 34, color: Colors.white),
          const SizedBox(height: 6),
          Text(temp,
              style: GoogleFonts.openSans(
                  fontSize: 14, color: Colors.white)),
          if (rain != null)
            Text('Mưa $rain',
                style: GoogleFonts.openSans(
                    fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }
}
