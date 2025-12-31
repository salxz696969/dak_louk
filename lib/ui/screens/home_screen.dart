import 'package:dak_louk/domain/services/post_service.dart';
import 'package:dak_louk/ui/widgets/category_bar.dart';
import 'package:dak_louk/ui/widgets/post_block.dart';
import 'package:dak_louk/domain/models/index.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  String selectedCategory = 'all';

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        CategoryBar(onCategorySelected: onCategorySelected),
        const SizedBox(height: 20.0),
        Expanded(
          child: FutureBuilder<List<PostModel>>(
            future: _postService.getAllPosts(selectedCategory, 100),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No posts found.'));
              }
              final posts = snapshot.data!;
              return ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16.0),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostBlock(post: posts[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
