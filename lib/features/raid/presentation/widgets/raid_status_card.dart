import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/raid_entity.dart';

class RaidStatusCard extends StatelessWidget {
  const RaidStatusCard({required this.raid, super.key});

  final RaidEntity raid;

  @override
  Widget build(BuildContext context) {
    final double progress = raid.slotsFilled / RaidEntity.maxSlots;

    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // OUTER GLOW
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFB84DFF).withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: const Color(0xFF6A00FF).withValues(alpha: 0.1),
                  blurRadius: 14,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),

          // MAIN DISC
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: <Color>[Color(0xFF24103F), Color(0xFF12051F)],
              ),
              border: Border.all(
                color: const Color(0xFF8D49FF).withValues(alpha: 0.6),
                width: 2,
              ),
            ),
          ),

          // OUTER RING
          SizedBox(
            width: 104,
            height: 104,
            child: CustomPaint(painter: _OuterRingPainter()),
          ),

          // PROGRESS RING
          SizedBox(
            width: 92,
            height: 92,
            child: CustomPaint(painter: _ProgressPainter(progress: progress)),
          ),

          // INNER DISC
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: <Color>[Color(0xFF251042), Color(0xFF14071F)],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),

          // CENTER TEXT
          Text(
            '${raid.slotsFilled} / ${RaidEntity.maxSlots}',
            style: const TextStyle(
              fontSize: 18,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Color(0xFFF3F3F3),
              shadows: <Shadow>[Shadow(color: Colors.white24, blurRadius: 8)],
            ),
          ),
        ],
      ),
    );
  }
}

class _OuterRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    // DIM OUTER TRACK
    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = const Color(0xFF6B2EDB).withValues(alpha: 0.22)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(6), 0, math.pi * 2, false, trackPaint);

    // BRIGHT EDGE GLOW
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFDA8CFF).withValues(alpha: 0.5);

    canvas.drawArc(rect.deflate(2), 0, math.pi * 2, false, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressPainter extends CustomPainter {
  const _ProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const double startAngle = math.pi * 0.72;
    const double sweepBase = math.pi * 1.55;

    final double sweepAngle = progress <= 0 ? 0 : progress * sweepBase;

    final Rect rect = Offset.zero & size;

    // BACK TRACK
    final Paint bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.08);

    canvas.drawArc(rect.deflate(6), startAngle, sweepBase, false, bgPaint);

    // GLOW
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = const Color(0xFFFF8BFF).withValues(alpha: 0.45);

    canvas.drawArc(rect.deflate(6), startAngle, sweepAngle, false, glowPaint);

    // MAIN PROGRESS
    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFFFB4FF),
          Color(0xFFE96CFF),
          Color(0xFFC94FFF),
        ],
      ).createShader(rect);

    canvas.drawArc(
      rect.deflate(6),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // START GLOW DOT
    final Offset startPoint = Offset(
      size.width / 2 + math.cos(startAngle) * (size.width / 2 - 6),
      size.height / 2 + math.sin(startAngle) * (size.height / 2 - 6),
    );

    final Paint dotPaint = Paint()..color = const Color(0xFFFFD5FF);

    canvas.drawCircle(startPoint, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
