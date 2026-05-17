import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class StreamMessagesUseCase {
  StreamMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Stream<List<ChatMessageEntity>> call(String raidId, String sessionId) {
    return _repository.streamMessages(raidId, sessionId);
  }
}

class SendMessageUseCase {
  SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  Future<void> call({
    required String raidId,
    required String userId,
    required String userName,
    required String message,
    required String sessionId,
  }) async {
    return _repository.sendMessage(
      raidId: raidId,
      userId: userId,
      userName: userName,
      message: message,
      sessionId: sessionId,
    );
  }
}

class GetOlderMessagesUseCase {
  GetOlderMessagesUseCase(this._repository);

  final ChatRepository _repository;

  Future<List<ChatMessageEntity>> call({
    required String raidId,
    required String sessionId,
    required DateTime lastMessageDate,
    int limit = 20,
  }) async {
    return _repository.getOlderMessages(
      raidId: raidId,
      sessionId: sessionId,
      lastMessageDate: lastMessageDate,
      limit: limit,
    );
  }
}
