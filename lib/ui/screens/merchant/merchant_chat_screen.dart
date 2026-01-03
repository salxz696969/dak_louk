import 'package:dak_louk/ui/widgets/merchant/chats/chat.dart';
import 'package:dak_louk/ui/widgets/merchant/merchant_app_bar.dart';
import 'package:flutter/material.dart';

class MerchantChatScreen extends StatelessWidget {
  final String targetUserName;
  final int chatRoomId;

  const MerchantChatScreen({
    super.key,
    required this.targetUserName,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MerchantAppBar(title: targetUserName),
      ),
      body: MerchantChat(chatRoomId: chatRoomId),
    );
  }
}
