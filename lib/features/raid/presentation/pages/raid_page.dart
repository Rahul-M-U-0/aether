import 'dart:io';

import 'package:aether/core/theme/app_colors.dart';
import 'package:aether/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:aether/features/chat/presentation/widgets/chat_view.dart';
import 'package:aether/features/raid/domain/entities/raid_entity.dart';
import 'package:aether/features/raid/presentation/widgets/cosmic_backgrounf.dart';
import 'package:aether/features/raid/presentation/widgets/raid_appbar.dart';
import 'package:aether/features/timer/presentation/widgets/world_boss_timer.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/di/injection.dart';
import '../cubit/raid_cubit.dart';
import '../cubit/raid_state.dart';
import '../widgets/join_raid_button.dart';
import '../widgets/raid_status_card.dart';

class RaidPage extends StatefulWidget {
  const RaidPage({super.key});

  @override
  State<RaidPage> createState() => _RaidPageState();
}

class _RaidPageState extends State<RaidPage> {
  final TextEditingController _nameController = TextEditingController();
  static String? _cachedDeviceId;
  String? _deviceId = _cachedDeviceId;

  @override
  void initState() {
    super.initState();
    if (_deviceId == null) {
      _getDeviceId();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? id;
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        id = androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        id = iosInfo.identifierForVendor;
      } else if (Platform.isWindows) {
        final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        id = windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
        id = macInfo.systemGUID;
      } else if (Platform.isLinux) {
        final LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        id = linuxInfo.machineId;
      }
    } catch (e) {
      id = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }

    if (mounted) {
      setState(() {
        _deviceId = id;
        _cachedDeviceId = id;
      });
    }
  }

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
      body: BlocProvider<ChatCubit>(
        create: (BuildContext context) => sl<ChatCubit>(),
        child: Stack(
          children: <Widget>[
            const CosmicBackground(),
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

                  if (raid == null || _deviceId == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  final bool isJoined = raid.members.any(
                    (RaidMember m) => m.id == _deviceId,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 8),
                        RepaintBoundary(
                          child: WorldBossTimer(
                            raidStartsAt: raid.raidStartsAt,
                            onTimerComplete: () async {
                              await context.read<RaidCubit>().resetRaid();
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (!isJoined && !raid.isFull) ...<Widget>[
                          _NameInput(controller: _nameController),
                          const SizedBox(height: 16),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaidStatusCard(raid: raid),
                            const SizedBox(width: 16),
                            Expanded(
                              child: JoinRaidButton(
                                isLoading: state.isLoading,
                                isFull: raid.isFull,
                                isJoined: isJoined,
                                onPressed: () {
                                  final String name = _nameController.text
                                      .trim();
                                  if (name.isEmpty) {
                                    _showAetherSnackBar(
                                      context,
                                      message: 'Please enter your name',
                                      icon: Icons.person_outline,
                                      iconColor: AppColors.warning,
                                    );
                                    return;
                                  }
                                  context.read<RaidCubit>().joinRaid(
                                    userId: _deviceId!,
                                    userName: name,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _RaidMembersHeader(isJoined: isJoined),

                        const SizedBox(height: 12),

                        Expanded(
                          child: isJoined
                              ? ChatView(
                                  raidId: FirestoreConstants.worldBossDocument,
                                  sessionId: raid.sessionId,
                                  currentUserId: _deviceId!,
                                  currentUserName: raid.members
                                      .firstWhere(
                                        (RaidMember m) => m.id == _deviceId,
                                        orElse: () => const RaidMember(
                                          id: '',
                                          name: 'Adventurer',
                                        ),
                                      )
                                      .name,
                                )
                              : (raid.members.isEmpty
                                    ? const _NoPlayersPlaceholder()
                                    : RepaintBoundary(
                                        child: ListView.separated(
                                          padding: const EdgeInsets.only(
                                            bottom: 16,
                                            left: 16,
                                            right: 16,
                                          ),
                                          itemCount: raid.members.length,
                                          separatorBuilder:
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                return const SizedBox(
                                                  height: 8,
                                                );
                                              },
                                          itemBuilder:
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                return _MemberTile(
                                                  index: index,
                                                  member: raid.members[index],
                                                );
                                              },
                                        ),
                                      )),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RaidMembersHeader extends StatelessWidget {
  const _RaidMembersHeader({required this.isJoined});

  final bool isJoined;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            isJoined ? 'RAID CHAT' : 'RAID MEMBERS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
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
    );
  }
}

class _NoPlayersPlaceholder extends StatelessWidget {
  const _NoPlayersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.group_rounded,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No players yet',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14103A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonPurple.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'ENTER YOUR NAME',
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
          prefixIcon: const Icon(
            Icons.person_pin_rounded,
            color: AppColors.neonPurple,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.index, required this.member});

  final int index;
  final RaidMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF14103A),
        border: Border.all(
          color: AppColors.neonPurple.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.neonPurple.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF4A00E0), Color(0xFF1B003A)],
              ),
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              member.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.shield, color: AppColors.metallicGoldDark, size: 20),
        ],
      ),
    );
  }
}
