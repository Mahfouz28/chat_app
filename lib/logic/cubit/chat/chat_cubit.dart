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

      final chatRoom = await chatRepo.getOrCreateChatRoom(
        currentUserId,
        otherUserId,
      );
      final initialMessages = await chatRepo.getMessages(chatRoom.id);

      emit(ChatLoaded(chatRoom: chatRoom, messages: initialMessages));

      // الاشتراك لتحديث الرسائل realtime
      _subscription = chatRepo.listenMessages(chatRoom.id).listen((messages) {
        emit(ChatLoaded(chatRoom: chatRoom, messages: messages));
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
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final newMessage = ChatMessageModel(
      id: '', // id تولده قاعدة البيانات
      chatRoomId: chatRoomId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      createdAt: DateTime.now().toLocal(),
      status: MessageStatus.sent,
    );

    // إرسال الرسالة
    await chatRepo.sendMessage(
      chatRoomId: chatRoomId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );

    // تحديث الرسائل محليًا مؤقتاً
    final updated = [...currentState.messages, newMessage];
    emit(ChatLoaded(chatRoom: currentState.chatRoom, messages: updated));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
