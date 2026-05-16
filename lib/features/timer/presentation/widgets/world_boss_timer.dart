import 'package:aether/core/di/injection.dart';
import 'package:aether/core/time/server_time_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorldBossTimer extends StatefulWidget {
  const WorldBossTimer({
    required this.raidStartsAt,
    required this.onTimerComplete,
    super.key,
  });

  final DateTime raidStartsAt;
  final Future<void> Function() onTimerComplete;

  @override
  State<WorldBossTimer> createState() => _WorldBossTimerState();
}

class _WorldBossTimerState extends State<WorldBossTimer>
    with SingleTickerProviderStateMixin {
  bool _hasTriggeredCompletion = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds <= 0) {
      return '00:00:00.0';
    }

    final Duration duration = Duration(milliseconds: milliseconds);

    final String hours = duration.inHours.toString().padLeft(2, '0');
    final String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    final String ms = ((duration.inMilliseconds % 1000) ~/ 100).toString();

    return '$hours:$minutes:$seconds.$ms';
  }

  Color _timerColor(int milliseconds) {
    if (milliseconds <= 10000) {
      return const Color(0xFFFF5A3C);
    }

    if (milliseconds <= 30000) {
      return const Color(0xFFFFB347);
    }

    if (milliseconds <= 60000) {
      return const Color(0xFFFFD54A);
    }

    return const Color(0xFFE9FF3A);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: Stream<int>.periodic(const Duration(milliseconds: 100), (_) {
        return widget.raidStartsAt
            .difference(sl<ServerTimeService>().now())
            .inMilliseconds;
      }),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 320,
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final int milliseconds = snapshot.data!;

        if (milliseconds <= 0 && !_hasTriggeredCompletion) {
          _hasTriggeredCompletion = true;

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await widget.onTimerComplete();
          });
        } else if (milliseconds > 0 && _hasTriggeredCompletion) {
          _hasTriggeredCompletion = false;
        }

        final String timeText = _formatDuration(milliseconds);
        final Color timerColor = _timerColor(milliseconds);

        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (BuildContext context, _) {
            return SizedBox(
              width: 340,
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  // CONTENT
                  Positioned.fill(
                    child: Stack(
                      children: <Widget>[
                        CustomPaint(
                          painter: HexBorderPainter(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            child: SizedBox(
                              height: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const _FlameIcon(),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          // TEXT GLOW
                                          Text(
                                            timeText,
                                            style: GoogleFonts.robotoMono(
                                              fontSize: 40,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.5,
                                              fontFeatures: const <FontFeature>[
                                                FontFeature.tabularFigures(),
                                              ],
                                              foreground: Paint()
                                                ..maskFilter =
                                                    const MaskFilter.blur(
                                                      BlurStyle.normal,
                                                      4,
                                                    )
                                                ..color = timerColor.withValues(
                                                  alpha:
                                                      0.95 *
                                                      _pulseAnimation.value,
                                                ),
                                            ),
                                          ),

                                          // MAIN TEXT
                                          ShaderMask(
                                            shaderCallback: (Rect bounds) {
                                              return LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: <Color>[
                                                  const Color(0xFFFFFFC7),
                                                  timerColor,
                                                  timerColor.withValues(
                                                    alpha: 0.85,
                                                  ),
                                                ],
                                              ).createShader(bounds);
                                            },
                                            child: Text(
                                              timeText,
                                              style: GoogleFonts.robotoMono(
                                                fontSize: 40,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.5,
                                                height: 1,
                                                fontFeatures: const <FontFeature>[
                                                  FontFeature.tabularFigures(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  const _FlameIcon(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FlameIcon extends StatelessWidget {
  const _FlameIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_fire_department_rounded,
        size: 26,
        color: Color(0xFFFFC933),
      ),
    );
  }
}

class HexBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double cut = 22;

    final Path path = Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(cut, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    // Glow border
    final Paint glowPaint = Paint()
      ..color = const Color(0xFFFFD84D).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Main border
    final Paint borderPaint = Paint()
      ..color = const Color(0xFFFFE45C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Inner highlight border
    final Paint innerPaint = Paint()
      ..color = const Color(0xFFFFF3A1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, borderPaint);

    // Slight inset for inner line
    canvas.save();
    canvas.translate(0.5, 0.5);
    canvas.drawPath(path, innerPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
