import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Widget hiển thị hiệu ứng mưa
class RainOverlay extends StatefulWidget {
  final bool isHeavy;
  final double intensity; // 0.0 - 1.0

  const RainOverlay({
    super.key,
    this.isHeavy = false,
    this.intensity = 0.7,
  });

  @override
  State<RainOverlay> createState() => _RainOverlayState();
}

class _RainOverlayState extends State<RainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<RainDrop> _raindrops = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Tạo giọt mưa
    final dropCount = widget.isHeavy ? 100 : 50;
    for (int i = 0; i < dropCount; i++) {
      _raindrops.add(RainDrop(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: widget.isHeavy
            ? 0.8 + _random.nextDouble() * 0.4
            : 0.5 + _random.nextDouble() * 0.3,
        length: widget.isHeavy ? 15.0 + _random.nextDouble() * 10 : 10.0 + _random.nextDouble() * 5,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RainPainter(
            raindrops: _raindrops,
            progress: _controller.value,
            intensity: widget.intensity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class RainDrop {
  final double x;
  final double y;
  final double speed;
  final double length;

  RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
  });
}

class RainPainter extends CustomPainter {
  final List<RainDrop> raindrops;
  final double progress;
  final double intensity;

  RainPainter({
    required this.raindrops,
    required this.progress,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5 * intensity)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (final drop in raindrops) {
      final x = drop.x * size.width;
      final y = ((drop.y + progress * drop.speed) % 1.0) * size.height;

      canvas.drawLine(
        Offset(x, y),
        Offset(x - 3, y + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) => true;
}

/// Widget hiển thị hiệu ứng tuyết
class SnowOverlay extends StatefulWidget {
  final double intensity;

  const SnowOverlay({
    super.key,
    this.intensity = 0.7,
  });

  @override
  State<SnowOverlay> createState() => _SnowOverlayState();
}

class _SnowOverlayState extends State<SnowOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Snowflake> _snowflakes = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    // Tạo bông tuyết
    for (int i = 0; i < 50; i++) {
      _snowflakes.add(Snowflake(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.1 + _random.nextDouble() * 0.2,
        size: 2.0 + _random.nextDouble() * 3,
        drift: -0.2 + _random.nextDouble() * 0.4,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SnowPainter(
            snowflakes: _snowflakes,
            progress: _controller.value,
            intensity: widget.intensity,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Snowflake {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double drift;

  Snowflake({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.drift,
  });
}

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;
  final double progress;
  final double intensity;

  SnowPainter({
    required this.snowflakes,
    required this.progress,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8 * intensity)
      ..style = PaintingStyle.fill;

    for (final flake in snowflakes) {
      final x = ((flake.x + flake.drift * progress) % 1.0) * size.width;
      final y = ((flake.y + progress * flake.speed) % 1.0) * size.height;

      canvas.drawCircle(Offset(x, y), flake.size, paint);
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) => true;
}

/// Widget hiển thị hiệu ứng sấm sét
class ThunderOverlay extends StatefulWidget {
  const ThunderOverlay({super.key});

  @override
  State<ThunderOverlay> createState() => _ThunderOverlayState();
}

class _ThunderOverlayState extends State<ThunderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();
  double _flashOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _controller.addListener(() {
      // Tạo sấm sét ngẫu nhiên
      if (_random.nextDouble() > 0.95) {
        setState(() {
          _flashOpacity = 0.6;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _flashOpacity = 0.0;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(_flashOpacity),
    );
  }
}

/// Widget hiển thị hiệu ứng mây di chuyển
class CloudOverlay extends StatefulWidget {
  final bool isDark;

  const CloudOverlay({
    super.key,
    this.isDark = false,
  });

  @override
  State<CloudOverlay> createState() => _CloudOverlayState();
}

class _CloudOverlayState extends State<CloudOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Cloud> _clouds = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    // Tạo mây
    for (int i = 0; i < 8; i++) {
      _clouds.add(Cloud(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.5, // chỉ ở nửa trên
        speed: 0.02 + _random.nextDouble() * 0.03,
        size: 40.0 + _random.nextDouble() * 60,
        opacity: 0.3 + _random.nextDouble() * 0.4,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CloudPainter(
            clouds: _clouds,
            progress: _controller.value,
            isDark: widget.isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Cloud {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double opacity;

  Cloud({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
  });
}

class CloudPainter extends CustomPainter {
  final List<Cloud> clouds;
  final double progress;
  final bool isDark;

  CloudPainter({
    required this.clouds,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final cloud in clouds) {
      final x = ((cloud.x + progress * cloud.speed) % 1.0) * size.width;
      final y = cloud.y * size.height;

      final paint = Paint()
        ..color = (isDark ? Colors.grey.shade600 : Colors.white)
            .withOpacity(cloud.opacity * 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      // Vẽ mây (3 hình tròn tạo hình mây)
      canvas.drawCircle(Offset(x, y), cloud.size * 0.5, paint);
      canvas.drawCircle(Offset(x + cloud.size * 0.5, y), cloud.size * 0.4, paint);
      canvas.drawCircle(Offset(x - cloud.size * 0.3, y), cloud.size * 0.35, paint);
    }
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) => true;
}

/// Widget hiển thị hiệu ứng sương mù
class FogOverlay extends StatefulWidget {
  const FogOverlay({super.key});

  @override
  State<FogOverlay> createState() => _FogOverlayState();
}

class _FogOverlayState extends State<FogOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade300.withOpacity(0.3 + _controller.value * 0.2),
                Colors.grey.shade200.withOpacity(0.2 + _controller.value * 0.15),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}
