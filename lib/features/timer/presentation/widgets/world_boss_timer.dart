import 'package:aether/core/di/injection.dart';
import 'package:aether/core/theme/app_colors.dart';
import 'package:aether/core/time/server_time_service.dart';
import 'package:flutter/material.dart';

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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
      return AppColors.error;
    }
    if (milliseconds <= 30000) {
      return AppColors.ember;
    }
    if (milliseconds <= 60000) {
      return AppColors.warning;
    }
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (BuildContext context, Widget? child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.surface.withValues(alpha: 0.9),
                AppColors.surfaceLight.withValues(alpha: 0.6),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: _pulseAnimation.value * 0.4,
              ),
              width: 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _pulseAnimation.value * 0.15,
                ),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: StreamBuilder<int>(
        stream: Stream<int>.periodic(const Duration(milliseconds: 100), (_) {
          return widget.raidStartsAt
              .difference(sl<ServerTimeService>().now())
              .inMilliseconds;
        }),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final int milliseconds = snapshot.data!;

          if (milliseconds <= 0 && !_hasTriggeredCompletion) {
            _hasTriggeredCompletion = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await widget.onTimerComplete();
              if (!mounted) {
                return;
              }
              _hasTriggeredCompletion = false;
            });
          }

          final Color timerColor = _timerColor(milliseconds);

          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.whatshot,
                    color: timerColor.withValues(alpha: 0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'WORLD BOSS SPAWNS IN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.whatshot,
                    color: timerColor.withValues(alpha: 0.8),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _formatDuration(milliseconds),
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: timerColor,
                  shadows: <Shadow>[
                    Shadow(
                      color: timerColor.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
