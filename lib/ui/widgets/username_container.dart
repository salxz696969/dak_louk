import 'package:dak_louk/db/dao/chat_dao.dart';
import 'package:dak_louk/db/dao/chat_room_dao.dart';
import 'package:dak_louk/models/chat_room_model.dart';
import 'package:dak_louk/ui/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:dak_louk/ui/screens/profile_screen.dart';
import 'package:flutter/material.dart';

class UsernameContainer extends StatelessWidget {
  final ImageProvider profile;
  final String username;
  final String rating;
  final int userId;
  final String bio;
  const UsernameContainer({
    super.key,
    required this.rating,
    required this.userId,
    required this.bio,
    required this.profile,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    userId: 1,
                    bio: bio,
                    username: username,
                    rating: rating,
                    profileImage: profile,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                CircleAvatar(backgroundImage: profile, radius: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.star, color: Colors.amber, size: 14),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            child: const Icon(CupertinoIcons.chat_bubble, size: 36),
            onTap: () async {
              final chatRoomId = await ChatRoomDao().getChatRoomId(1, userId);
              if (chatRoomId != -1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      targetUserName: username,
                      chatDao: ChatDao().getChatByChatRoomId(chatRoomId),
                    ),
                  ),
                );
              } else {
                final newChatRoom = ChatRoomModel(
                  id: 1,
                  userId: 1,
                  targetUserId: userId,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                final newChatRoomId = await ChatRoomDao().insertChatRoom(
                  newChatRoom,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      targetUserName: username,
                      chatDao: ChatDao().getChatByChatRoomId(newChatRoomId),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
