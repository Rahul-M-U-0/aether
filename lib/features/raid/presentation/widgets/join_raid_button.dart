import 'package:aether/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class JoinRaidButton extends StatefulWidget {
  const JoinRaidButton({
    required this.onPressed,
    required this.isLoading,
    required this.isFull,
    this.isJoined = false,
    super.key,
  });

  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFull;
  final bool isJoined;

  @override
  State<JoinRaidButton> createState() => _JoinRaidButtonState();
}

class _JoinRaidButtonState extends State<JoinRaidButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _glow = Tween<double>(
      begin: 0.45,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _updateGlow();
  }

  @override
  void didUpdateWidget(covariant JoinRaidButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateGlow();
  }

  void _updateGlow() {
    if (widget.isLoading || widget.isFull || widget.isJoined) {
      _controller.stop();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.isLoading || widget.isFull || widget.isJoined;

    return AnimatedBuilder(
      animation: _glow,
      builder: (BuildContext context, Widget? child) {
        return Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: disabled
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: const Color(
                        0xFFCB4DFF,
                      ).withValues(alpha: _glow.value * 0.55),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(
                        0xFF7A00FF,
                      ).withValues(alpha: _glow.value * 0.25),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
          ),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: disabled ? null : widget.onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: _RaidButtonPainter(disabled: disabled),
                ),
              ),

              // SMALL STAR FLARE
              if (!disabled)
                const Positioned(top: -5, right: 8, child: _Flare()),

              SizedBox(
                height: 58,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              widget.isJoined
                                  ? Icons.check_circle_outline
                                  : (widget.isFull
                                        ? Icons.lock_outline
                                        : Icons.bolt),
                              size: 22,
                              color: disabled
                                  ? AppColors.textSecondary
                                  : const Color(0xFF2A0A38),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              widget.isJoined
                                  ? 'JOINED'
                                  : (widget.isFull ? 'RAID FULL' : 'JOIN RAID'),
                              style: TextStyle(
                                fontSize: 17,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: disabled
                                    ? AppColors.textSecondary
                                    : const Color(0xFF2A0A38),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RaidButtonPainter extends CustomPainter {
  const _RaidButtonPainter({required this.disabled});

  final bool disabled;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );

    final RRect inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      const Radius.circular(8),
    );

    // OUTER BORDER
    final Paint borderPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: disabled
            ? <Color>[const Color(0xFF555566), const Color(0xFF2F2F3D)]
            : <Color>[const Color(0xFFFF92FF), const Color(0xFF9A34FF)],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(outer, borderPaint);

    // MAIN BODY
    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: disabled
            ? <Color>[const Color(0xFF2B2B36), const Color(0xFF1B1B24)]
            : <Color>[const Color(0xFFC45EFF), const Color(0xFF922EFF)],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(inner, bodyPaint);

    // TOP GLOSS
    if (!disabled) {
      final Paint glossPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.2, 0.45],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.5));

      canvas.drawRRect(inner, glossPaint);
    }

    // INNER LIGHT STROKE
    if (!disabled) {
      canvas.drawRRect(
        inner.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RaidButtonPainter oldDelegate) {
    return oldDelegate.disabled != disabled;
  }
}

class _Flare extends StatelessWidget {
  const _Flare();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.95),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFFFF8BFF).withValues(alpha: 0.9),
                  blurRadius: 22,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          Container(
            width: 26,
            height: 1.8,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.transparent,
                  Colors.white,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          Container(
            width: 1.8,
            height: 26,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.transparent,
                  Colors.white,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
