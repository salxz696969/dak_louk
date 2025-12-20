import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UsernameContainer extends StatelessWidget {
  final ImageProvider profile;
  final String username;
  final String rating;
  const UsernameContainer({
    super.key,
    required this.rating,
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
          Row(
            children: [
              CircleAvatar(backgroundImage: profile, radius: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(rating, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 2),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                    ],
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            child: const Icon(CupertinoIcons.chat_bubble, size: 36),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
