import '../entities/chat_message_entity.dart';

abstract interface class ChatRepository {
  Stream<List<ChatMessageEntity>> streamMessages(
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
  Future<List<ChatMessageEntity>> getOlderMessages({
    required String raidId,
    required String sessionId,
    required DateTime lastMessageDate,
    int limit = 20,
  });
}
