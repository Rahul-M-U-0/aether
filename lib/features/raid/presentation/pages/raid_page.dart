import 'package:aether/core/theme/app_colors.dart';
import 'package:aether/features/raid/domain/entities/raid_entity.dart';
import 'package:aether/features/timer/presentation/widgets/world_boss_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/raid_cubit.dart';
import '../cubit/raid_state.dart';
import '../widgets/join_raid_button.dart';
import '../widgets/raid_status_card.dart';

class RaidPage extends StatelessWidget {
  const RaidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('AETHER')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0F0C29),
              Color(0xFF0A0E21),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<RaidCubit, RaidState>(
            listener: (BuildContext context, RaidState state) {
              if (state.joinSuccess == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: <Widget>[
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text('Successfully joined raid'),
                      ],
                    ),
                  ),
                );
              }

              if (state.joinSuccess == false) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text('Raid is full'),
                      ],
                    ),
                  ),
                );
              }

              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.warning_amber,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(state.errorMessage!)),
                      ],
                    ),
                  ),
                );
              }

              if (state.resetSuccess == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: <Widget>[
                        Icon(
                          Icons.campaign,
                          color: AppColors.accentGold,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text('The World Boss has spawned!'),
                      ],
                    ),
                  ),
                );
              }
            },
            builder: (BuildContext context, RaidState state) {
              final RaidEntity? raid = state.raid;

              if (raid == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 8),

                    WorldBossTimer(
                      raidStartsAt: raid.raidStartsAt,
                      onTimerComplete: () async {
                        await context.read<RaidCubit>().resetRaid();
                      },
                    ),

                    const SizedBox(height: 16),

                    RaidStatusCard(raid: raid),

                    const SizedBox(height: 16),

                    JoinRaidButton(
                      isLoading: state.isLoading,
                      isFull: raid.isFull,
                      onPressed: () {
                        context.read<RaidCubit>().joinRaid(
                          userId: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'RAID MEMBERS',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: raid.members.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.group_off,
                                    size: 48,
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No players yet',
                                    style: TextStyle(
                                      color: AppColors.textSecondary
                                          .withValues(alpha: 0.5),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: raid.members.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(height: 8);
                              },
                              itemBuilder:
                                  (BuildContext context, int index) {
                                return _MemberTile(
                                  index: index,
                                  memberId: raid.members[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.index,
    required this.memberId,
  });

  final int index;
  final String memberId;

  @override
  Widget build(BuildContext context) {
    final String shortId = memberId.length > 4
        ? memberId.substring(memberId.length - 4)
        : memberId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface.withValues(alpha: 0.5),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primary, AppColors.primaryDark],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Player #$shortId',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.shield_outlined,
            color: AppColors.primary.withValues(alpha: 0.4),
            size: 20,
          ),
        ],
      ),
    );
  }
}
