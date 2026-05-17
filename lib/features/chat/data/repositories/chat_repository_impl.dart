import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Stream<List<ChatMessageEntity>> streamMessages(
    String raidId,
    String sessionId,
  ) {
    return _remoteDataSource.streamMessages(raidId, sessionId);
  }

  @override
  Future<void> sendMessage({
    required String raidId,
    required String userId,
    required String userName,
    required String message,
    required String sessionId,
  }) async {
    return _remoteDataSource.sendMessage(
      raidId: raidId,
      userId: userId,
      userName: userName,
      message: message,
      sessionId: sessionId,
    );
  }

  @override
  Future<List<ChatMessageEntity>> getOlderMessages({
    required String raidId,
    required String sessionId,
    required DateTime lastMessageDate,
    int limit = 20,
  }) async {
    final List<ChatMessageModel> models = await _remoteDataSource
        .getOlderMessages(
          raidId: raidId,
          sessionId: sessionId,
          lastMessageDate: lastMessageDate,
          limit: limit,
        );
    return models;
  }
}
