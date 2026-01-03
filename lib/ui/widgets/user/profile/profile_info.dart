import 'package:dak_louk/core/auth/app_session.dart';
import 'package:dak_louk/ui/screens/auth_screen.dart';
import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String username;
  final String profileImage;
  final String bio;

  const ProfileInfo({
    super.key,
    required this.username,
    required this.profileImage,
    required this.bio,
  });

  void _handleLogout(BuildContext context) {
    AppSession.instance.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(profileImage),
                    ),
                    const SizedBox(width: 8),
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
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Log Out',
                onPressed: () => _handleLogout(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4),
            child: Text(bio, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
