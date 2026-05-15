import '../entities/raid_entity.dart';

abstract interface class RaidRepository {
  Stream<RaidEntity> watchRaid();

  Future<bool> joinRaid({required String userId});

  Future<void> resetRaid();
}
