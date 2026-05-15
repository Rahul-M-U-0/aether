import 'package:aether/core/constants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServerTimeService {
  ServerTimeService(this._firestore);

  final FirebaseFirestore _firestore;

  Duration _offset = Duration.zero;

  Future<void> sync() async {
    final DocumentReference<Map<String, dynamic>> ref = _firestore
        .collection(FirestoreConstants.serverCollection)
        .doc(FirestoreConstants.clockDocument);

    // Ask Firestore server for current server time
    await ref.set(<String, Object>{'time': FieldValue.serverTimestamp()});

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    final Timestamp timestamp = snapshot.data()!['time'] as Timestamp;

    final DateTime serverTime = timestamp.toDate();

    final DateTime deviceTime = DateTime.now();

    _offset = serverTime.difference(deviceTime);
  }

  DateTime now() {
    return DateTime.now().add(_offset);
  }
}
