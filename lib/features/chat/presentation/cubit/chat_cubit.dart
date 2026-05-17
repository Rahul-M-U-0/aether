import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required StreamMessagesUseCase streamMessages,
    required SendMessageUseCase sendMessage,
    required GetOlderMessagesUseCase getOlderMessages,
  }) : _streamMessages = streamMessages,
       _sendMessage = sendMessage,
       _getOlderMessages = getOlderMessages,
       super(const ChatState());

  final StreamMessagesUseCase _streamMessages;
  final SendMessageUseCase _sendMessage;
  final GetOlderMessagesUseCase _getOlderMessages;

  StreamSubscription<List<ChatMessageEntity>>? _messageSubscription;
  String? _currentRaidId;
  String? _currentSessionId;

  void init(String raidId, String sessionId) {
    if (_currentRaidId == raidId && _currentSessionId == sessionId) return;
    _currentRaidId = raidId;
    _currentSessionId = sessionId;

    // RESET STATE for new raid/session to avoid message leak from previous sessions
    emit(const ChatState(isLoading: true));

    _messageSubscription?.cancel();
    _messageSubscription = _streamMessages(raidId, sessionId).listen(
      (List<ChatMessageEntity> latestMessages) {
        // We merge latest messages from stream with any older paginated messages
        _updateMessages(latestMessages);
      },
      onError: (_) {
        emit(state.copyWith(isLoading: false, hasError: true));
      },
    );
  }

  void _updateMessages(List<ChatMessageEntity> latestMessages) {
    final List<ChatMessageEntity> currentMessages =
        List<ChatMessageEntity>.from(state.messages);

    // Create a map for quick lookup and deduplication
    final Map<String, ChatMessageEntity> messageMap =
        <String, ChatMessageEntity>{};

    // Add existing messages to map
    for (final ChatMessageEntity msg in currentMessages) {
      messageMap[msg.id] = msg;
    }

    // Update/Add latest messages from stream
    for (final ChatMessageEntity msg in latestMessages) {
      messageMap[msg.id] = msg;
    }

    // Sort all messages by date descending
    final List<ChatMessageEntity> sortedMessages = messageMap.values.toList()
      ..sort(
        (ChatMessageEntity a, ChatMessageEntity b) =>
            b.createdAt.compareTo(a.createdAt),
      );

    emit(state.copyWith(messages: sortedMessages, isLoading: false));
  }

  Future<void> sendChatMessage({
    required String userId,
    required String userName,
    required String message,
  }) async {
    if (message.trim().isEmpty ||
        _currentRaidId == null ||
        _currentSessionId == null) {
      return;
    }

    emit(state.copyWith(isSending: true));

    try {
      await _sendMessage(
        raidId: _currentRaidId!,
        userId: userId,
        userName: userName,
        message: message,
        sessionId: _currentSessionId!,
      );
      emit(state.copyWith(isSending: false));
    } catch (_) {
      emit(state.copyWith(isSending: false, hasError: true));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        !state.canLoadMore ||
        _currentRaidId == null ||
        _currentSessionId == null ||
        state.messages.isEmpty) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final List<ChatMessageEntity> olderMessages = await _getOlderMessages(
        raidId: _currentRaidId!,
        sessionId: _currentSessionId!,
        lastMessageDate: state.messages.last.createdAt,
      );

      if (olderMessages.isEmpty) {
        emit(state.copyWith(isLoadingMore: false, canLoadMore: false));
        return;
      }

      final Map<String, ChatMessageEntity> messageMap =
          <String, ChatMessageEntity>{};
      for (final ChatMessageEntity msg in state.messages) {
        messageMap[msg.id] = msg;
      }
      for (final ChatMessageEntity msg in olderMessages) {
        messageMap[msg.id] = msg;
      }

      final List<ChatMessageEntity> sortedMessages = messageMap.values.toList()
        ..sort(
          (ChatMessageEntity a, ChatMessageEntity b) =>
              b.createdAt.compareTo(a.createdAt),
        );

      emit(
        state.copyWith(
          messages: sortedMessages,
          isLoadingMore: false,
          canLoadMore: olderMessages.length >= 20,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false, hasError: true));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
