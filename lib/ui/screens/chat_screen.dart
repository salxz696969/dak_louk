import 'package:dak_louk/ui/widgets/common/appbar.dart';
import 'package:dak_louk/ui/widgets/screens/user/chat/chat.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String targetUserName;
  final int chatRoomId;
  ChatScreen({
    super.key,
    required this.targetUserName,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Appbar(title: targetUserName),
      ),
      body: Chat(chatRoomId: chatRoomId),
    );
  }
}
