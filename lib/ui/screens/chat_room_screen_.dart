import 'package:dak_louk/domain/services/chat_room_service.dart';
import 'package:dak_louk/domain/services/chat_service.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChatRoomVM>>(
      future: ChatRoomService().getAllChatRooms(),
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
                    backgroundImage: AssetImage(
                      chatRoom.targetUserProfileImage ?? '',
                    ),
                  ),
                  title: Text(
                    chatRoom.targetUserName ?? '',
                    style: TextStyle(
                      fontWeight: chatRoom.hasUnreadMessages
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: chatRoom.hasUnreadMessages
                      ? Text(
                          'You: ${chatRoom.lastMessage}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      : Text(
                          chatRoom.lastMessage ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                  trailing: chatRoom.hasUnreadMessages
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
                          targetUserName: chatRoom.targetUserName ?? '',
                          chatService: ChatService().getChatsByChatRoomId(
                            chatRoom.id,
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
