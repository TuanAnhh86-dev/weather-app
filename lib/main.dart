import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';
import 'services/weather_service.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env trước khi run app
  await dotenv.load(fileName: ".env"); // fileName mặc định là ".env" nên có thể bỏ nếu tên đúng

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy API key từ dotenv (an toàn hơn, không cần ! nữa)
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? 'your_default_key_if_missing';
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(
        WeatherService(apiKey),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}