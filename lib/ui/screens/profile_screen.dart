import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/user_service.dart';
import 'package:dak_louk/ui/widgets/profile/profile_info.dart';
import 'package:dak_louk/ui/widgets/profile/profile_liked_posts.dart';
import 'package:dak_louk/ui/widgets/profile/profile_saved_posts.dart';
import 'package:dak_louk/ui/widgets/profile/profile_tabs.dart';
import 'package:flutter/material.dart';

// (1) PROFILE TABS ENUM
enum ProfileTabsEnum {
  likedPosts('Liked', Icons.favorite_border),
  savedPosts('Saved', Icons.bookmark_border);

  final String label;
  final IconData icon;
  const ProfileTabsEnum(this.label, this.icon);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  late ProfileTabsEnum selectedTab = ProfileTabsEnum.likedPosts;

  late Future<UserProfileVM> _userFuture;
  late Future<List<UserProfileLikedSavedPostsVM>> _likedPostsFuture;
  late Future<List<UserProfileLikedSavedPostsVM>> _savedPostsFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserProfile();
    _likedPostsFuture = _userService.getLikedPosts();
    _savedPostsFuture = _userService.getSavedPosts();
  }

  void onTabSelected(ProfileTabsEnum tab) {
    setState(() {
      selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfileVM>(
      future: _userFuture,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }
        final user = userSnapshot.data!;
        return Column(
          children: [
            // If you want to keep the AppBar, you may return it here, 
            // otherwise remove the _ProfileAppBar if you want absolutely no AppBar!
            // _ProfileAppBar(title: user.username), // Optionally include as a widget (not as AppBar)
            const SizedBox(height: 30),
            ProfileInfo(
              username: user.username,
              profileImage: user.profileImageUrl,
              bio: user.bio,
            ),
            const SizedBox(height: 24),
            ProfileTabs(
              selectedTab: selectedTab,
              onTabSelected: onTabSelected,
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                // Show the correct posts widget based on the selected tab
                if (selectedTab == ProfileTabsEnum.likedPosts) {
                  return FutureBuilder<List<UserProfileLikedSavedPostsVM>>(
                    future: _likedPostsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(child: Text('Error: ${snapshot.error}')),
                        );
                      }
                      final likedPosts = snapshot.data ?? [];
                      return LikedPosts(likedPosts: likedPosts);
                    },
                  );
                } else if (selectedTab == ProfileTabsEnum.savedPosts) {
                  return FutureBuilder<List<UserProfileLikedSavedPostsVM>>(
                    future: _savedPostsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(child: Text('Error: ${snapshot.error}')),
                        );
                      }
                      final savedPosts = snapshot.data ?? [];
                      return SavedPosts(savedPosts: savedPosts);
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// (3) PROFILE APP BAR
class _ProfileAppBar extends StatelessWidget {
  final String title;
  const _ProfileAppBar({required this.title});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
    );
  }
}
