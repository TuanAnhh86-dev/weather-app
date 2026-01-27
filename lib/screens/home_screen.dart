import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import '../models/weather.dart';
import '../models/forecast.dart'; // Giả sử bạn đã tạo file này

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Thời tiết',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm thành phố... (ví dụ: Cầu Giấy, Hà Nội)',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (value) => _searchCity(provider, value),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : provider.error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                provider.error!,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : provider.weather == null
                            ? _buildInitialUI()
                            : _buildWeatherUI(provider.weather!, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _searchCity(WeatherProvider provider, String value) {
    final city = value.trim();
    if (city.isNotEmpty) {
      provider.getWeather(city);
      _controller.clear();
    }
  }

  Widget _buildInitialUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_outlined,
              size: 120, color: Colors.white.withOpacity(0.7)),
          const SizedBox(height: 24),
          Text(
            'Nhập tên thành phố để xem thời tiết',
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherUI(Weather w, WeatherProvider provider) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            w.city,
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 32 : 42,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${w.temp.round()}°C',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 80 : 100,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              height: 0.9,
            ),
          ),
          Text(
            'Cảm giác như ${w.feelsLike.round()}°C',
            style: GoogleFonts.poppins(
                fontSize: isSmall ? 18 : 22, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            w.description.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 16 : 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Info Grid responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final aspect = constraints.maxWidth < 360 ? 1.3 : 1.1;


              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: aspect,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final items = [
                    _InfoItem(
                        icon: Icons.water_drop,
                        label: 'Độ ẩm',
                        value: '${w.humidity}%'),
                    _InfoItem(
                        icon: Icons.air,
                        label: 'Gió',
                        value: '${w.windSpeed.toStringAsFixed(1)} m/s'),
                    _InfoItem(
                        icon: Icons.visibility,
                        label: 'Tầm nhìn',
                        value:
                            '${(w.visibility / 1000).toStringAsFixed(1)} km'),
                    _InfoItem(
                        icon: Icons.compress,
                        label: 'Áp suất',
                        value: '${w.pressure} hPa'),
                  ];
                  return items[index];
                },
              );
            },
          ),

          const SizedBox(height: 32),

          // Dự báo thật
          Text(
            'Dự báo',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isSmall ? 170 : 160,
            child: provider.forecasts.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white70))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.forecasts.length,
                    itemBuilder: (context, index) {
                      final f = provider.forecasts[index];
                      return _ForecastCard(
                        day: f.date,
                        temp: '${f.minTemp.round()} ~ ${f.maxTemp.round()}',
                        icon: _mapIcon(f.icon), // hàm map icon bạn đã có
                        rain: f.rainChance != null && f.rainChance! > 0
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

  IconData _mapIcon(String iconCode) {
    // Map cơ bản từ OpenWeather icon code
    switch (iconCode) {
      case '01d':
      case '01n':
        return Icons.wb_sunny;
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
        return Icons.filter_drama;
      default:
        return Icons.cloud;
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), // ⬅ giảm padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 28), // ⬅ icon nhỏ hơn
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12, // ⬅ nhỏ hơn
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView( // ✅ FIX OVERFLOW
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 6),
            FittedBox(
              child: Text(
                temp,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            if (rain != null) ...[
              const SizedBox(height: 4),
              Text(
                'Mưa $rain',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

