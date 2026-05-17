import 'package:aether/core/constants/firestore_constants.dart';
import 'package:aether/core/time/server_time_service.dart';
import 'package:aether/features/raid/data/datasources/raid_remote_datasource.dart';
import 'package:aether/features/raid/data/repositories/raid_repository_impl.dart';
import 'package:aether/features/raid/domain/repositories/raid_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Aether Raid Concurrency Integrity', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ServerTimeService timeService;
    late RaidRepository raidRepository;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      timeService = ServerTimeService(fakeFirestore);
      final RaidRemoteDataSource remoteDataSource = RaidRemoteDataSource(
        fakeFirestore,
        timeService,
      );
      raidRepository = RaidRepositoryImpl(remoteDataSource);

      await fakeFirestore
          .collection(FirestoreConstants.raidsCollection)
          .doc(FirestoreConstants.worldBossDocument)
          .set(<String, Object>{
            'slotsFilled': 0,
            'members': <dynamic>[],
            'raidStartsAt': Timestamp.fromDate(
              DateTime.now().add(const Duration(minutes: 5)),
            ),
            'sessionId': 'session_12345',
          });
    });

    test(
      'Thundering Herd: 50 simultaneous join requests must strictly cap at 15',
      () async {
        final List<Future<bool>> joinRequests = <Future<bool>>[];

        for (int i = 0; i < 50; i++) {
          try {
            joinRequests.add(
              raidRepository.joinRaid(userId: 'user_$i', userName: 'Hero $i'),
            );
          } catch (e) {
            fail('💡 HEALING ACTION: joinRaid() crashed. Error: $e');
          }
        }

        final List<bool> results = await Future.wait(joinRequests);
        final int successfulJoins = results
            .where((bool result) => result == true)
            .length;

        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await fakeFirestore
                .collection(FirestoreConstants.raidsCollection)
                .doc(FirestoreConstants.worldBossDocument)
                .get();
        final int slotsFilled = snapshot.data()?['slotsFilled'] as int? ?? 0;

        expect(
          successfulJoins,
          15,
          reason:
              '💡 HEALING ACTION: Exactly 15 requests should report success (return true) to the client. The rest must gracefully return false.',
        );
        expect(
          slotsFilled,
          15,
          reason:
              '💡 HEALING ACTION: The database must record exactly 15 filled slots. If this is higher, your code suffers from a race condition. Use Transactions.',
        );
      },
    );
  });
}
