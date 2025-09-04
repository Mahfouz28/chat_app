import 'package:equatable/equatable.dart';
import 'package:chat_app/data/model/chat_messege_model.dart';
import 'package:chat_app/data/model/chat_mode_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة المبدئية
class ChatInitial extends ChatState {}

/// تحميل البيانات (رسائل/غرفة)
class ChatLoading extends ChatState {}

/// لما الرسائل والغرفة تبقى جاهزة
class ChatLoaded extends ChatState {
  final ChatRoomModel chatRoom;
  final List<ChatMessageModel> messages;
  final bool isTyping;
  final String? typingUserId;

  ChatLoaded({
    required this.chatRoom,
    required this.messages,
    this.isTyping = false,
    this.typingUserId,
  });

  ChatLoaded copyWith({
    ChatRoomModel? chatRoom,
    List<ChatMessageModel>? messages,
    bool? isTyping,
    String? typingUserId,
  }) {
    return ChatLoaded(
      chatRoom: chatRoom ?? this.chatRoom,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      typingUserId: typingUserId ?? this.typingUserId,
    );
  }

  @override
  List<Object?> get props => [chatRoom, messages, isTyping, typingUserId];
}

/// لما رسالة تتبعت بنجاح
class MessageSent extends ChatState {
  final ChatMessageModel message;
  MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// تحديث جزء من الداتا (رسالة جديدة - تحديث حالة قراءة)
class ChatUpdated extends ChatState {
  final List<ChatMessageModel> messages;
  ChatUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// آخر رسالة مش متشافه (عشان شاشة الـ chat list)
class ChatLastUnseenLoaded extends ChatState {
  final ChatMessageModel message;
  ChatLastUnseenLoaded(this.message);

  @override
  List<Object?> get props => [message];
}

/// لو حصل خطأ
class ChatError extends ChatState {
  final String message;
  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
