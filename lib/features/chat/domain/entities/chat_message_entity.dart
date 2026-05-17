import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    userId,
    userName,
    message,
    createdAt,
  ];
}
