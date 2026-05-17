import 'package:equatable/equatable.dart';

class RaidMember extends Equatable {
  const RaidMember({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object> get props => <Object>[id, name];

  Map<String, String> toMap() {
    return <String, String>{'id': id, 'name': name};
  }

  factory RaidMember.fromMap(Map<String, dynamic> map) {
    return RaidMember(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
    );
  }
}

class RaidEntity extends Equatable {
  const RaidEntity({
    required this.slotsFilled,
    required this.members,
    required this.raidStartsAt,
    required this.sessionId,
  });

  /// Maximum number of players allowed in a single raid.
  static const int maxSlots = 15;

  final int slotsFilled;
  final List<RaidMember> members;
  final DateTime raidStartsAt;
  final String sessionId;

  bool get isFull => slotsFilled >= maxSlots;

  int get remainingSlots => maxSlots - slotsFilled;

  @override
  List<Object> get props => <Object>[
    slotsFilled,
    members,
    raidStartsAt,
    sessionId,
  ];
}
