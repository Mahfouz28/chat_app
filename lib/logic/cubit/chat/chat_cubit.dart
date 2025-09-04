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

  /// تحديث رسالة واحدة عند مشاهدتها
  Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      final currentState = state;
      if (currentState is! ChatLoaded) return;

      final updatedMessages = currentState.messages.map((msg) {
        if (msg.id == messageId && !msg.seenBy.contains(userId)) {
          final updatedMsg = msg.copyWith(
            status: MessageStatus.read,
            seenBy: [...msg.seenBy, userId],
          );

          // تحديث قاعدة البيانات لكل رسالة
          chatRepo.markAsRead(msg.id, userId, currentState.chatRoom.id);

          return updatedMsg;
        }
        return msg;
      }).toList();

      // تحديث حالة آخر رسالة في الغرفة
      if (updatedMessages.isNotEmpty) {
        final lastMessage = updatedMessages.last;
        chatRepo.updateChatRoomLastMessageStatus(
          currentState.chatRoom.id,
          lastMessage.status.name,
        );
      }

      emit(currentState.copyWith(messages: updatedMessages));
    } catch (e) {
      print("Error in markMessageAsRead: $e");
    }
  }

  /// Batch update: كل الرسائل في الغرفة تقرأ
  Future<void> markAllAsRead(String chatRoomId, String userId) async {
    try {
      final currentState = state;
      if (currentState is! ChatLoaded) return;

      final updatedMessages = currentState.messages.map((msg) {
        if (msg.senderId != userId && !msg.seenBy.contains(userId)) {
          chatRepo.markAsRead(msg.id, userId, chatRoomId);
          return msg.copyWith(
            status: MessageStatus.read,
            seenBy: [...msg.seenBy, userId],
          );
        }
        return msg;
      }).toList();

      // تحديث last_message_status للغرفة
      chatRepo.updateChatRoomLastMessageStatus(
        chatRoomId,
        MessageStatus.read.name,
      );

      emit(currentState.copyWith(messages: updatedMessages));
    } catch (e) {
      print("Error in markAllAsRead: $e");
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
