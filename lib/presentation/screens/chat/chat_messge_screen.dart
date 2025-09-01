import 'package:chat_app/logic/cubit/chat/chat_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chat_app/logic/cubit/chat/chat_cubit.dart';
import 'package:chat_app/data/model/chat_messege_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/config/theme/app_theme.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ChatMessgeScreen extends StatefulWidget {
  const ChatMessgeScreen({super.key, this.receviedId, this.receviedName});

  final String? receviedId;
  final String? receviedName;

  @override
  State<ChatMessgeScreen> createState() => _ChatMessgeScreenState();
}

class _ChatMessgeScreenState extends State<ChatMessgeScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadChat(
      Supabase.instance.client.auth.currentUser!.id,
      widget.receviedId!,
    );
  }

  Future<void> handelSendMessege() async {
    final chatCubit = context.read<ChatCubit>();
    if (chatCubit.state is! ChatLoaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Chat not ready yet!")));
      return;
    }

    final chatRoomID = (chatCubit.state as ChatLoaded).chatRoom.id;
    final messegeText = messageController.text.trim();
    if (messegeText.isEmpty) return;

    chatCubit.sendMessage(
      chatRoomId: chatRoomID,
      senderId: Supabase.instance.client.auth.currentUser!.id,
      receiverId: widget.receviedId!,
      content: messegeText,
    );

    messageController.clear();
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
                } else if (state is ChatError) {
                  return Center(child: Text("Error: ${state.message}"));
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
                        totalRepeatCount: 5,
                        pause: const Duration(milliseconds: 900),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe =
                          msg.senderId ==
                          Supabase.instance.client.auth.currentUser!.id;
                      return MessegeBubbel(
                        chatMessage: msg,
                        isMe: isMe,
                        showTime: true,
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: AppTheme.primaryColor,
                    size: 40,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: InputBorder.none,
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: AppTheme.primaryColor,
                    size: 35,
                  ),
                  onPressed: handelSendMessege,
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).primaryColor.withOpacity(0.8)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    chatMessage.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                8.horizontalSpace,
                Icon(
                  Icons.done_all,
                  size: 16.sp,
                  color: chatMessage.status == MessageStatus.read
                      ? Colors.blue
                      : Colors.white,
                ),
              ],
            ),
          ),
          if (showTime)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                _formatTime(chatMessage.createdAt),
                style: TextStyle(fontSize: 10.sp, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    return "${local.hour}:${local.minute.toString().padLeft(2, '0')}";
  }
}
