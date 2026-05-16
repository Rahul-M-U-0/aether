import 'package:aether/core/errors/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/raid_entity.dart';

class RaidModel extends RaidEntity {
  const RaidModel({
    required super.slotsFilled,
    required super.members,
    required super.raidStartsAt,
  });

  factory RaidModel.fromMap(Map<String, dynamic> map) {
    return RaidModel(
      slotsFilled: map['slotsFilled'] as int? ?? 0,
      members: (map['members'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic m) => RaidMember.fromMap(m as Map<String, dynamic>))
          .toList(),
      raidStartsAt: map['raidStartsAt'] != null
          ? (map['raidStartsAt'] as Timestamp).toDate()
          : throw AppException('Raid document missing raidStartsAt field'),
    );
  }
}
