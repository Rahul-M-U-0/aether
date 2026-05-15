import 'package:aether/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class JoinRaidButton extends StatefulWidget {
  const JoinRaidButton({
    required this.onPressed,
    required this.isLoading,
    required this.isFull,
    super.key,
  });

  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFull;

  @override
  State<JoinRaidButton> createState() => _JoinRaidButtonState();
}

class _JoinRaidButtonState extends State<JoinRaidButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _updateGlow();
  }

  @override
  void didUpdateWidget(JoinRaidButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateGlow();
  }

  void _updateGlow() {
    if (widget.isLoading || widget.isFull) {
      _glowController.stop();
    } else if (!_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.isLoading || widget.isFull;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary
                          .withValues(alpha: _glowAnimation.value * 0.4),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: isDisabled
                  ? null
                  : const LinearGradient(
                      colors: <Color>[
                        AppColors.primaryDark,
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    ),
              color: isDisabled ? AppColors.surface : null,
              border: Border.all(
                color: isDisabled
                    ? AppColors.textSecondary.withValues(alpha: 0.2)
                    : AppColors.primaryLight.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (widget.isLoading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.textPrimary,
                      ),
                    )
                  else ...<Widget>[
                    Icon(
                      widget.isFull ? Icons.lock_outline : Icons.bolt,
                      size: 22,
                      color: isDisabled
                          ? AppColors.textSecondary
                          : Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.isFull ? 'RAID FULL' : 'JOIN RAID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: isDisabled
                            ? AppColors.textSecondary
                            : Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
