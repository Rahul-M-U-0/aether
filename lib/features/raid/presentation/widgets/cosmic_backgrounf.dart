import 'dart:math';

import 'package:flutter/material.dart';

class CosmicBackground extends StatelessWidget {
  const CosmicBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Base dark gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF09001F),
                Color(0xFF12002E),
                Color(0xFF060012),
              ],
            ),
          ),
        ),

        // Nebula glows
        const Positioned(
          top: -80,
          left: -60,
          child: GlowOrb(size: 240, color: Color(0xFF8A2BE2)),
        ),

        const Positioned(
          top: 180,
          right: -40,
          child: GlowOrb(size: 220, color: Color(0xFF00BFFF)),
        ),

        const Positioned(
          bottom: 120,
          left: -50,
          child: GlowOrb(size: 260, color: Color(0xFF7B1FA2)),
        ),

        const Positioned(
          bottom: -50,
          right: -30,
          child: GlowOrb(size: 220, color: Color(0xFF512DA8)),
        ),

        // Purple overlay mist
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: <Color>[
                Colors.purple.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Stars
        const StarField(),

        // Extra shimmer
        const Positioned(top: 220, right: 20, child: StarGlow()),
      ],
    );
  }
}

class GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const GlowOrb({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            color.withValues(alpha: 0.65),
            color.withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class StarField extends StatelessWidget {
  const StarField({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: StarPainter(), size: Size.infinite);
  }
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(4);

    for (int i = 0; i < 140; i++) {
      final double dx = random.nextDouble() * size.width;
      final double dy = random.nextDouble() * size.height;

      final double radius = random.nextDouble() * 1.8;

      final Paint paint = Paint()
        ..color = Colors.white.withValues(alpha: random.nextDouble() * 0.8);

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StarGlow extends StatelessWidget {
  const StarGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.pinkAccent.withValues(alpha: 0.9),
            blurRadius: 35,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
