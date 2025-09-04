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

  /// تحديث كل الرسائل في الغرفة (Batch)
  Future<void> markAllAsRead(String chatRoomId, String userId) async {
    try {
      await chatRepo.markAsRead(chatRoomId, userId, chatRoomId);

      final currentState = state;
      if (currentState is ChatLoaded) {
        final updatedMessages = currentState.messages.map((msg) {
          if (msg.senderId != userId && msg.status != MessageStatus.read) {
            return msg.copyWith(
              status: MessageStatus.read,
              seenBy: [...msg.seenBy, userId],
            );
          }
          return msg;
        }).toList();
        print(
          '=========================markAllAsRead called, updatedMessages: $updatedMessages',
        );
        emit(currentState.copyWith(messages: updatedMessages));
      }
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
