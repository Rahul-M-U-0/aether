import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../models/chat_message_model.dart';

abstract interface class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> streamMessages(
    String raidId,
    String sessionId,
  );
  Future<void> sendMessage({
    required String raidId,
    required String userId,
    required String userName,
    required String message,
    required String sessionId,
  });
  Future<List<ChatMessageModel>> getOlderMessages({
    required String raidId,
    required String sessionId,
    required DateTime lastMessageDate,
    int limit = 20,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _getMessagesRef(
    String raidId,
    String sessionId,
  ) {
    return _firestore
        .collection(FirestoreConstants.raidsCollection)
        .doc(raidId)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages');
  }

  @override
  Stream<List<ChatMessageModel>> streamMessages(
    String raidId,
    String sessionId,
  ) {
    // Optimization: Limiting to 30 latest messages reduces initial read costs.
    // Deep subcollection path (raids/{raidId}/sessions/{sessionId}/messages)
    // provides automatic isolation without complex queries or indexes.
    return _getMessagesRef(raidId, sessionId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
          return snapshot.docs.map((
            QueryDocumentSnapshot<Map<String, dynamic>> doc,
          ) {
            return ChatMessageModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  @override
  Future<void> sendMessage({
    required String raidId,
    required String userId,
    required String userName,
    required String message,
    required String sessionId,
  }) async {
    final ChatMessageModel model = ChatMessageModel(
      id: '',
      userId: userId,
      userName: userName,
      message: message,
      createdAt: DateTime.now(), // Will be replaced by serverTimestamp in toMap
    );

    await _getMessagesRef(raidId, sessionId).add(model.toMap());
  }

  @override
  Future<List<ChatMessageModel>> getOlderMessages({
    required String raidId,
    required String sessionId,
    required DateTime lastMessageDate,
    int limit = 20,
  }) async {
    // Pagination: loading older messages based on the timestamp of the last loaded message.
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _getMessagesRef(raidId, sessionId)
            .orderBy('createdAt', descending: true)
            .startAfter(<Object?>[Timestamp.fromDate(lastMessageDate)])
            .limit(limit)
            .get();

    return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      return ChatMessageModel.fromMap(doc.data(), doc.id);
    }).toList();
  }
}
