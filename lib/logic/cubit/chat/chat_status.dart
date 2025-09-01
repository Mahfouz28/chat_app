import 'package:equatable/equatable.dart';
import 'package:chat_app/data/model/chat_messege_model.dart';
import 'package:chat_app/data/model/chat_mode_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final ChatModeModel chatRoom;
  final List<ChatMessageModel> messages;

  ChatLoaded({required this.chatRoom, required this.messages});

  @override
  List<Object?> get props => [chatRoom, messages];
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
