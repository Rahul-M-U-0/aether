import 'package:aether/features/chat/domain/entities/chat_message_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import 'chat_message_tile.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    required this.raidId,
    required this.sessionId,
    required this.currentUserId,
    required this.currentUserName,
    super.key,
  });

  final String raidId;
  final String sessionId;
  final String currentUserId;
  final String currentUserName;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().init(widget.raidId, widget.sessionId);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.raidId != widget.raidId ||
        oldWidget.sessionId != widget.sessionId) {
      context.read<ChatCubit>().init(widget.raidId, widget.sessionId);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final String text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatCubit>().sendChatMessage(
        userId: widget.currentUserId,
        userName: widget.currentUserName,
        message: text,
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // MESSAGE LIST
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (BuildContext context, ChatState state) {
              if (state.isLoading && state.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state.hasError && state.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load chat',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      TextButton(
                        onPressed: () => context.read<ChatCubit>().init(
                          widget.raidId,
                          widget.sessionId,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state.messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet. Start the conversation!',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true, // Show latest messages at the bottom
                itemCount:
                    state.messages.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == state.messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final ChatMessageEntity message = state.messages[index];
                  final bool isMe = message.userId == widget.currentUserId;

                  return ChatMessageTile(
                    key: ValueKey<String>(message.id),
                    message: message,
                    isMe: isMe,
                  );
                },
              );
            },
          ),
        ),

        // INPUT FIELD
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF14103A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.neonPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.primary,
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
