import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UsernameContainer extends StatelessWidget {
  final ImageProvider profile;
  final String username;
  const UsernameContainer({
    super.key,
    required this.profile,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundImage: profile, radius: 16),
        const SizedBox(width: 8.0),
        Text(
          username,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8.0),
        InkWell(
          onTap: () {},
          child: Icon(CupertinoIcons.chat_bubble, size: 26),
        ),
      ],
    );
  }
}
