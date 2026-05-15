import 'package:aether/core/constants/firestore_constants.dart';
import 'package:aether/core/errors/app_exception.dart';
import 'package:aether/core/time/server_time_service.dart';
import 'package:aether/features/raid/data/models/raid_model.dart';
import 'package:aether/features/raid/domain/entities/raid_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RaidRemoteDataSource {
  RaidRemoteDataSource(this._firestore, this._timeService);

  final FirebaseFirestore _firestore;
  final ServerTimeService _timeService;

  DocumentReference<Map<String, dynamic>> get _raidRef {
    return _firestore
        .collection(FirestoreConstants.raidsCollection)
        .doc(FirestoreConstants.worldBossDocument);
  }

  // Watch raid
  Stream<RaidModel> watchRaid() {
    return _raidRef.snapshots().map((
      DocumentSnapshot<Map<String, dynamic>> snapshot,
    ) {
      final Map<String, dynamic>? data = snapshot.data();

      if (data == null) {
        throw AppException('Raid document not found');
      }

      return RaidModel.fromMap(data);
    });
  }

  // Join raid
  Future<bool> joinRaid({required String userId}) async {
    return _firestore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction
          .get(_raidRef);

      final Map<String, dynamic>? data = snapshot.data();

      if (data == null) {
        throw AppException('Raid document not found');
      }

      final int slotsFilled = data['slotsFilled'] as int? ?? 0;

      final List<String> members = List<String>.from(
        data['members'] as List<dynamic>? ?? <dynamic>[],
      );

      // User already joined
      if (members.contains(userId)) {
        return true;
      }

      // No slots available — uses domain constant as single source of truth
      if (slotsFilled >= RaidEntity.maxSlots) {
        return false;
      }

      // Join the raid
      transaction.update(_raidRef, <String, Object>{
        'slotsFilled': slotsFilled + 1,
        'members': FieldValue.arrayUnion(<String>[userId]),
      });

      return true;
    });
  }

  // Reset raid if it has started
  Future<void> resetRaid() async {
    await _firestore.runTransaction((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction
          .get(_raidRef);

      final Map<String, dynamic>? data = snapshot.data();

      if (data == null) {
        throw AppException('Raid document not found');
      }

      final DateTime raidStartsAt = (data['raidStartsAt'] as Timestamp)
          .toDate();

      // Another client already reset it
      if (raidStartsAt.isAfter(_timeService.now())) {
        return;
      }

      transaction.update(_raidRef, <String, Object>{
        'slotsFilled': 0,
        'members': <String>[],
        'raidStartsAt': Timestamp.fromDate(
          _timeService.now().add(const Duration(minutes: 5)),
        ),
      });
    });
  }
}
