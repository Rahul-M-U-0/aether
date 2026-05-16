import 'package:aether/core/theme/app_colors.dart';
import 'package:aether/features/raid/domain/entities/raid_entity.dart';
import 'package:aether/features/raid/presentation/widgets/cosmic_backgrounf.dart';
import 'package:aether/features/raid/presentation/widgets/raid_appbar.dart';
import 'package:aether/features/timer/presentation/widgets/world_boss_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/raid_cubit.dart';
import '../cubit/raid_state.dart';
import '../widgets/join_raid_button.dart';
import '../widgets/raid_status_card.dart';

class RaidPage extends StatelessWidget {
  const RaidPage({super.key});

  void _showAetherSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface.withValues(alpha: 0.9),
          elevation: 8,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: iconColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          content: Row(
            children: <Widget>[
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(child: AetherAppbar()),
      ),
      body: Stack(
        children: <Widget>[
          // Background
          const CosmicBackground(),

          // Body
          SafeArea(
            child: BlocConsumer<RaidCubit, RaidState>(
              listener: (BuildContext context, RaidState state) {
                if (state.joinSuccess == true) {
                  _showAetherSnackBar(
                    context,
                    message: 'Successfully joined raid',
                    icon: Icons.check_circle,
                    iconColor: AppColors.success,
                  );
                }

                if (state.joinSuccess == false) {
                  _showAetherSnackBar(
                    context,
                    message: 'Raid is full',
                    icon: Icons.error_outline,
                    iconColor: AppColors.error,
                  );
                }

                if (state.errorMessage != null) {
                  _showAetherSnackBar(
                    context,
                    message: state.errorMessage!,
                    icon: Icons.warning_amber,
                    iconColor: AppColors.warning,
                  );
                }

                if (state.resetSuccess == true) {
                  _showAetherSnackBar(
                    context,
                    message: 'The World Boss has spawned!',
                    icon: Icons.campaign,
                    iconColor: AppColors.accentGold,
                  );
                }
              },
              builder: (BuildContext context, RaidState state) {
                final RaidEntity? raid = state.raid;

                if (raid == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
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

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaidStatusCard(raid: raid),
                          const SizedBox(width: 16),
                          Expanded(
                            child: JoinRaidButton(
                              isLoading: state.isLoading,
                              isFull: raid.isFull,
                              onPressed: () {
                                context.read<RaidCubit>().joinRaid(
                                  userId: DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                                );
                              },
                            ),
                          ),
                        ],
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
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.8,
                                ),
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
                                      Icons.group_rounded,
                                      size: 48,
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.3,
                                      ),
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
                                padding: const EdgeInsets.only(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                ),
                                itemCount: raid.members.length,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                      return const SizedBox(height: 8);
                                    },
                                itemBuilder: (BuildContext context, int index) {
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
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.index, required this.memberId});

  final int index;
  final String memberId;

  @override
  Widget build(BuildContext context) {
    final String shortId = memberId.length > 4
        ? memberId.substring(memberId.length - 4)
        : memberId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF14103A),
        border: Border.all(
          color: AppColors.neonPurple.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.neonPurple.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF4A00E0), Color(0xFF1B003A)],
              ),
              border: Border.all(color: AppColors.primaryLight, width: 1),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.shield, color: AppColors.metallicGoldDark, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Player #$shortId',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
