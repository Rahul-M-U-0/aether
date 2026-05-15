import 'package:aether/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/raid_entity.dart';

class RaidStatusCard extends StatelessWidget {
  const RaidStatusCard({required this.raid, super.key});

  final RaidEntity raid;

  @override
  Widget build(BuildContext context) {
    final double progress = raid.slotsFilled / RaidEntity.maxSlots;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.surface.withValues(alpha: 0.8),
            AppColors.surfaceLight.withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.shield,
                color: AppColors.accent,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'WORLD BOSS RAID',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: AppColors.textGold,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.shield,
                color: AppColors.accent,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${raid.slotsFilled} / ${RaidEntity.maxSlots}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: raid.isFull
                      ? AppColors.error.withValues(alpha: 0.2)
                      : AppColors.success.withValues(alpha: 0.15),
                  border: Border.all(
                    color: raid.isFull
                        ? AppColors.error.withValues(alpha: 0.5)
                        : AppColors.success.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  raid.isFull
                      ? 'FULL'
                      : '${raid.remainingSlots} OPEN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: raid.isFull
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildProgressBar(progress),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.background.withValues(alpha: 0.8),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: constraints.maxWidth * progress.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: LinearGradient(
                  colors: progress >= 1.0
                      ? <Color>[AppColors.error, AppColors.ember]
                      : <Color>[AppColors.primary, AppColors.primaryLight],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: (progress >= 1.0
                            ? AppColors.error
                            : AppColors.primary)
                        .withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
