import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_app/config/theme/app_theme.dart';
import 'package:chat_app/data/model/chat_messege_model.dart';
import 'package:chat_app/logic/cubit/chat/chat_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/logic/cubit/chat/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatMessgeScreen extends StatefulWidget {
  const ChatMessgeScreen({super.key, this.receviedId, this.receviedName});

  final String? receviedId;
  final String? receviedName;

  @override
  State<ChatMessgeScreen> createState() => _ChatMessgeScreenState();
}

class _ChatMessgeScreenState extends State<ChatMessgeScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;
    context.read<ChatCubit>().loadChat(currentUserId, widget.receviedId!);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.receviedName ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "?",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            12.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text(
                  "Online",
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatLoaded) {
                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return Center(
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Say Hi 👋',
                            cursor: '',
                            textStyle: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                            speed: const Duration(milliseconds: 200),
                          ),
                        ],
                        repeatForever: true,
                      ),
                    );
                  }

                  final currentUserId =
                      Supabase.instance.client.auth.currentUser!.id;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final reversedMessages = messages.reversed.toList();
                      final msg = reversedMessages[index];
                      final isMe = msg.senderId == currentUserId;

                      // ====== Update seenBy automatically for incoming messages =====
                      if (!isMe && !msg.seenBy.contains(currentUserId)) {
                        context.read<ChatCubit>().markAllAsRead(
                          msg.id,
                          currentUserId,
                        );
                      }

                      return MessegeBubbel(
                        chatMessage: msg,
                        isMe: isMe,
                        showTime: true,
                      );
                    },
                  );
                } else if (state is ChatError) {
                  return Center(child: Text("Error: ${state.message}"));
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // ===== Box تبع كتابة الرسالة =====
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      size: 24.sp,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: null,
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      if (_messageController.text.trim().isEmpty) return;

                      final currentState = context.read<ChatCubit>().state;
                      if (currentState is ChatLoaded) {
                        context.read<ChatCubit>().sendMessage(
                          chatRoomId: currentState.chatRoom.id,
                          senderId:
                              Supabase.instance.client.auth.currentUser!.id,
                          receiverId: widget.receviedId!,
                          content: _messageController.text.trim(),
                        );
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessegeBubbel extends StatelessWidget {
  const MessegeBubbel({
    super.key,
    required this.chatMessage,
    required this.isMe,
    required this.showTime,
  });

  final ChatMessageModel chatMessage;
  final bool isMe;
  final bool showTime;

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[700],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              chatMessage.content,
              style: const TextStyle(color: Colors.white),
            ),
            if (showTime)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(chatMessage.createdAt),
                    style: TextStyle(fontSize: 8.sp, color: Colors.white70),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 8.w),
                    Icon(
                      chatMessage.status == MessageStatus.sent
                          ? Icons.done_outlined
                          : chatMessage.status == MessageStatus.delivered
                          ? Icons.done_all_outlined
                          : Icons.done_all_outlined,
                      size: 16.sp,
                      color: chatMessage.status == MessageStatus.read
                          ? Colors.lightBlueAccent
                          : Colors.white70,
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
