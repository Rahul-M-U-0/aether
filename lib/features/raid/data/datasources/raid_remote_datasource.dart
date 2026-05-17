import 'dart:async';

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

  // In-memory queue lock to serialize transactions for testing with FakeFirebaseFirestore
  Future<dynamic> _transactionLock = Future<dynamic>.value();

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
  Future<bool> joinRaid({
    required String userId,
    required String userName,
  }) async {
    final Completer<bool> completer = Completer<bool>();
    _transactionLock = _transactionLock.whenComplete(() async {
      try {
        final bool result =
            await _firestore.runTransaction((Transaction transaction) async {
          final DocumentSnapshot<Map<String, dynamic>> snapshot =
              await transaction.get(_raidRef);

          final Map<String, dynamic>? data = snapshot.data();

          if (data == null) {
            throw AppException('Raid document not found');
          }

          final int slotsFilled = data['slotsFilled'] as int? ?? 0;

          final List<dynamic> membersRaw =
              data['members'] as List<dynamic>? ?? <dynamic>[];
          final List<RaidMember> members = membersRaw
              .map((dynamic m) => RaidMember.fromMap(m as Map<String, dynamic>))
              .toList();

          // User already joined
          if (members.any((RaidMember m) => m.id == userId)) {
            return true;
          }

          // Name already taken by someone else
          if (members.any((RaidMember m) => m.name == userName)) {
            throw AppException('The name "$userName" is already taken.');
          }

          // No slots available — uses domain constant as single source of truth
          if (slotsFilled >= RaidEntity.maxSlots) {
            return false;
          }

          final RaidMember newMember = RaidMember(id: userId, name: userName);

          // Join the raid
          transaction.update(_raidRef, <String, Object>{
            'slotsFilled': slotsFilled + 1,
            'members': FieldValue.arrayUnion(<Map<String, String>>[
              newMember.toMap(),
            ]),
          });

          return true;
        });
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }

  // Reset raid if it has started
  Future<void> resetRaid() async {
    final Completer<void> completer = Completer<void>();
    _transactionLock = _transactionLock.whenComplete(() async {
      try {
        await _firestore.runTransaction((Transaction transaction) async {
          final DocumentSnapshot<Map<String, dynamic>> snapshot =
              await transaction.get(_raidRef);

          final Map<String, dynamic>? data = snapshot.data();

          if (data == null) {
            throw AppException('Raid document not found');
          }

          final DateTime raidStartsAt =
              (data['raidStartsAt'] as Timestamp).toDate();

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
            'sessionId':
                'session_${_timeService.now().millisecondsSinceEpoch}',
          });
        });
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    });
    return completer.future;
  }
}
