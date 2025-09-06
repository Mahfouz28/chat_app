import 'dart:io';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/data/model/chat_messege_model.dart'; // Import for MessageStatus
import 'package:chat_app/data/repo/chat_repo.dart';
import 'package:chat_app/logic/cubit/chat/chat_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Remove enum MessageStatus { sent, delivered, read } from here
// Use the one from chat_messege_model.dart

class ChatCubit extends Cubit<ChatState> {
  // Removed duplicate MessageType enum
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
    String type = 'text', // Ensure type is a String as expected by ChatRepo
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

          chatRepo.markAsRead(msg.id, userId, currentState.chatRoom.id);

          return updatedMsg;
        }
        return msg;
      }).toList();

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

  Future<void> sendVoiceMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required File file,
  }) async {
    try {
      if (Supabase.instance.client.auth.currentUser == null) {
        throw Exception("User not authenticated");
      }

      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final pathInBucket =
          'voices/$chatRoomId/$fileName'; // Explicitly include 'voices' folder

      print('Uploading to bucket: chat-voices, full path: $pathInBucket');
      final url = await chatRepo.uplodeVoiceFile(
        file: file,
        pathInBucket: pathInBucket,
      );

      if (url.isEmpty) {
        throw Exception("Failed to generate valid URL for voice file");
      }

      print('Upload successful, URL: $url');
      await chatRepo.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: receiverId,
        content: url, // Removed duplicate MessageType enum
        type: 'voice', // Convert enum to String
      );

      final currentState = state;
      if (currentState is ChatLoaded) {
        final newMessage = ChatMessageModel(
          id: '', // Generate or fetch real ID later
          chatRoomId: chatRoomId,
          senderId: senderId,
          receiverId: receiverId,
          content: url, // Use String representation
          type: 'voice', // Use String representation
          status: MessageStatus.sent, // Use enum from chat_messege_model.dart
          seenBy: [senderId],
          createdAt: DateTime.now(),
        );
        emit(
          currentState.copyWith(
            messages: [...currentState.messages, newMessage],
          ),
        );
      }
    } catch (e) {
      print('Error in sendVoiceMessage: $e');
      emit(ChatError("Failed to send voice message: $e"));
    }
  }
}
