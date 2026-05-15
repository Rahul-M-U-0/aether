import 'package:equatable/equatable.dart';

class RaidEntity extends Equatable {
  const RaidEntity({
    required this.slotsFilled,
    required this.members,
    required this.raidStartsAt,
  });

  /// Maximum number of players allowed in a single raid.
  static const int maxSlots = 15;

  final int slotsFilled;
  final List<String> members;
  final DateTime raidStartsAt;

  bool get isFull => slotsFilled >= maxSlots;

  int get remainingSlots => maxSlots - slotsFilled;

  @override
  List<Object> get props => <Object>[slotsFilled, members, raidStartsAt];
}
