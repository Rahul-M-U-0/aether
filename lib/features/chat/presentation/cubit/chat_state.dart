import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatState extends Equatable {
  const ChatState({
    this.messages = const <ChatMessageEntity>[],
    this.isLoading = false,
    this.isSending = false,
    this.hasError = false,
    this.canLoadMore = true,
    this.isLoadingMore = false,
  });

  final List<ChatMessageEntity> messages;
  final bool isLoading;
  final bool isSending;
  final bool hasError;
  final bool canLoadMore;
  final bool isLoadingMore;

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isLoading,
    bool? isSending,
    bool? hasError,
    bool? canLoadMore,
    bool? isLoadingMore,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      hasError: hasError ?? this.hasError,
      canLoadMore: canLoadMore ?? this.canLoadMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    messages,
    isLoading,
    isSending,
    hasError,
    canLoadMore,
    isLoadingMore,
  ];
}
