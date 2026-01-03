
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/screens/user/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatroomTile extends StatelessWidget {
  final ChatRoomVM chatRoom;
  const ChatroomTile({super.key, required this.chatRoom});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(chatRoom.merchantProfileImage),
          ),
          title: Text(
            chatRoom.merchantName,
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          subtitle: Text(
            chatRoom.latestText,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: Text(chatRoom.timeAgo),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  targetUserName: chatRoom.merchantName,
                  chatRoomId: chatRoom.id,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
