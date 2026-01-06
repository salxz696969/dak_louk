import 'package:dak_louk/domain/services/user/chat_room_service.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/widgets/user/chatroom/chatroom_tile.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatRoomService _chatRoomService = ChatRoomService();
    return FutureBuilder<List<ChatRoomVM>>(
      future: _chatRoomService.getAllChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No chat rooms found.'));
        }
        final chatRooms = snapshot.data!;
        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            return ChatroomTile(chatRoom: chatRoom);
          },
        );
      },
    );
  }
}
