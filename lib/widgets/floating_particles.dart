import 'dart:math';
import 'package:flutter/material.dart';

class FloatingParticles extends StatefulWidget {
  final int particleCount;
  final Color particleColor;

  const FloatingParticles({
    super.key,
    this.particleCount = 50,
    this.particleColor = const Color(0x669D4EDD),
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        _updateParticles();
        setState(() {});
      });
    _controller.repeat();
  }

  void _initializeParticles() {
    final random = Random();
    particles = List.generate(widget.particleCount, (index) {
      return Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 2 + random.nextDouble() * 2,
        speed: 0.001 + random.nextDouble() * 0.002,
        opacity: 0.2 + random.nextDouble() * 0.6,
        horizontalDrift: (random.nextDouble() - 0.5) * 0.001,
      );
    });
  }

  void _updateParticles() {
    final random = Random();
    for (var particle in particles) {
      particle.y -= particle.speed;
      particle.x += particle.horizontalDrift;

      // Reset particle when it goes off screen
      if (particle.y < 0) {
        particle.y = 1.0;
        particle.x = random.nextDouble();
      }
      if (particle.x < 0) particle.x = 1.0;
      if (particle.x > 1) particle.x = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(
        particles: particles,
        color: widget.particleColor,
      ),
      size: Size.infinite,
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double horizontalDrift;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.horizontalDrift,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;

  ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = Color.fromRGBO(
          color.red,
          color.green,
          color.blue,
          particle.opacity,
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
