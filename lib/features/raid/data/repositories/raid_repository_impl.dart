import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/raid_entity.dart';
import '../../domain/repositories/raid_repository.dart';
import '../datasources/raid_remote_datasource.dart';

class RaidRepositoryImpl implements RaidRepository {
  RaidRepositoryImpl(this._remoteDataSource);

  final RaidRemoteDataSource _remoteDataSource;

  @override
  Future<bool> joinRaid({
    required String userId,
    required String userName,
  }) async {
    try {
      return await _remoteDataSource.joinRaid(
        userId: userId,
        userName: userName,
      );
    } on FirebaseException catch (e) {
      throw AppException('Failed to join raid: ${e.message}');
    }
  }

  @override
  Stream<RaidEntity> watchRaid() {
    return _remoteDataSource.watchRaid();
  }

  @override
  Future<void> resetRaid() async {
    try {
      await _remoteDataSource.resetRaid();
    } on FirebaseException catch (e) {
      throw AppException('Failed to reset raid: ${e.message}');
    }
  }
}
