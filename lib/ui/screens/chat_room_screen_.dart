import 'package:dak_louk/db/dao/chat_dao.dart';
import 'package:dak_louk/services/chat_room_service.dart';
import 'package:dak_louk/services/chat_service.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/ui/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChatRoomModel>>(
      future: ChatRoomService().getAllChatRoomsByUserId(1),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts found.'));
        }
        final chatRooms = snapshot.data!;
        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            final chatRoomUI = chatRoom.ui();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(chatRoomUI.targetUserAvatarUrl),
                  ),
                  title: Text(
                    chatRoomUI.targetUserName,
                    style: TextStyle(
                      fontWeight: chatRoomUI.areYouLatestToChat
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: chatRoomUI.areYouLatestToChat
                      ? Text(
                          'You: ${chatRoomUI.latestChat}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      : Text(
                          chatRoomUI.latestChat,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                  trailing: chatRoomUI.areYouLatestToChat
                      ? null
                      : Icon(
                          Icons.circle,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 12,
                        ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          targetUserName: chatRoom.ui().targetUserName,
                          chatService: ChatService()
                              .getChatsByUserIdAndTargetUserId(
                                1,
                                chatRoom.targetUserId,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
