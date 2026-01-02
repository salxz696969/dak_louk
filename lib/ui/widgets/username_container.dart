import 'package:dak_louk/domain/services/chat_service.dart';
import 'package:dak_louk/domain/services/chat_room_service.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/screens/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:dak_louk/ui/screens/merchant_profile_screen.dart';
import 'package:flutter/material.dart';

class UsernameContainer extends StatelessWidget {
  final ImageProvider profile;
  final String username;
  final String rating;
  final int merchantId;
  final String bio;
  const UsernameContainer({
    super.key,
    required this.rating,
    required this.merchantId,
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
                  builder: (context) => MerchantProfileScreen(
                    merchant: MerchantVM(
                      id: merchantId,
                      username: username,
                      rating: double.parse(rating),
                      bio: bio,
                      profileImage: profile.toString(),
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
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
              final chatRoomId = await ChatRoomService().getChatRoomId(
                merchantId,
              );
              if (chatRoomId != -1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      targetUserName: username,
                      chatService: ChatService().getChatsByChatRoomId(
                        chatRoomId,
                      ),
                    ),
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      targetUserName: username,
                      chatService: ChatService().getChatsByChatRoomId(
                        chatRoomId,
                      ),
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
