import 'package:equatable/equatable.dart';

import '../../domain/entities/raid_entity.dart';

class RaidState extends Equatable {
  const RaidState({
    this.raid,
    this.isLoading = false,
    this.errorMessage,
    this.joinSuccess,
    this.resetSuccess,
  });

  final RaidEntity? raid;
  final bool isLoading;
  final String? errorMessage;
  final bool? joinSuccess;
  final bool? resetSuccess;

  RaidState copyWith({
    RaidEntity? raid,
    bool? isLoading,
    String? errorMessage,
    bool? joinSuccess,
    bool? resetSuccess,
  }) {
    return RaidState(
      raid: raid ?? this.raid,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      joinSuccess: joinSuccess,
      resetSuccess: resetSuccess,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    raid,
    isLoading,
    errorMessage,
    joinSuccess,
    resetSuccess,
  ];
}
