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
      final message = await chatRepo.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
      );

      final currentState = state;
      if (currentState is ChatLoaded) {
        emit(
          ChatLoaded(
            chatRoom: currentState.chatRoom,
            messages: [...currentState.messages, message]
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
          ),
        );
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> markMessageAsRead(String messageId, String userId) async {
    await chatRepo.markAsRead(messageId, userId);
  }

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
