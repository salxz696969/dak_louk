import 'package:dak_louk/models/chat_model.dart';
import 'package:dak_louk/ui/widgets/appbar.dart';
import 'package:dak_louk/ui/widgets/chat.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String targetUserName;
  final Future<List<ChatModel>> chatDao;
  const ChatScreen({
    super.key,
    required this.targetUserName,
    required this.chatDao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Appbar(title: targetUserName),
      ),
      body: Chat(
        chatDao: chatDao,
      ),
    );
  }
}
