import 'package:flutter/material.dart';

class AetherAppbar extends StatelessWidget {
  const AetherAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFFF59D), // light gold
            Color(0xFFFFD54F), // gold
            Color(0xFFFFB300), // darker gold
          ],
        ).createShader(bounds);
      },
      child: const Center(
        child: Text(
          'AETHER',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                color: Color(0xFFFFC107),
                blurRadius: 10,
                offset: Offset(0, 0),
              ),
              Shadow(
                color: Color(0xFFFFA000),
                blurRadius: 18,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
