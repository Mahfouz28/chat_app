import 'package:chat_app/logic/cubit/chat/chat_status.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/data/model/chat_messege_model.dart';
import 'package:chat_app/data/repo/chat_repo.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepo;
  ChatCubit(this.chatRepo) : super(ChatInitial());

  StreamSubscription<List<ChatMessageModel>>? _subscription;

  Future<void> loadChat(String currentUserId, String otherUserId) async {
    try {
      emit(ChatLoading());

      final chatRoom = await chatRepo.getOrCreateRoom(
        currentUserId,
        otherUserId,
      );

      final initialMessages = await chatRepo.getMessages(chatRoom.id);

      emit(ChatLoaded(chatRoom: chatRoom, messages: initialMessages));

      _subscription = chatRepo.listenMessages(chatRoom.id).listen((messages) {
        final currentState = state;
        if (currentState is ChatLoaded) {
          emit(currentState.copyWith(messages: messages));
        } else {
          emit(ChatUpdated(messages));
        }
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      // إرسال الرسالة فقط، دون تعديل state
      await chatRepo.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  /// تحديث حالة الرسالة عند القراءة
  Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      await chatRepo.markAsRead(messageId, userId);

      final currentState = state;
      if (currentState is ChatLoaded) {
        // نحدث الرسالة محليًا كمان
        final updatedMessages = currentState.messages.map((msg) {
          if (msg.id == messageId) {
            return msg.copyWith(
              status: MessageStatus.read,
              seenBy: [...msg.seenBy, userId],
            );
          }
          return msg;
        }).toList();

        emit(currentState.copyWith(messages: updatedMessages));
      }
    } catch (e) {
      print("Error marking as read: $e");
    }
  }

  /// حالة الكتابة
  void setTyping(bool isTyping, {String? typingUserId}) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(
        currentState.copyWith(isTyping: isTyping, typingUserId: typingUserId),
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
