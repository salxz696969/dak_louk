import 'package:dak_louk/domain/services/post_service.dart';
import 'package:dak_louk/ui/widgets/screens/user/posts/category_bar.dart';
import 'package:dak_louk/ui/widgets/screens/user/posts/post_item.dart';
import 'package:dak_louk/ui/widgets/screens/user/posts/product_item.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _postService = PostService();
  ProductCategory selectedCategory = ProductCategory.all;

  void onCategorySelected(ProductCategory category) {
    setState(() {
      selectedCategory = category;
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
          child: FutureBuilder<List<PostVM>>(
            future: _postService.getAllPosts(
              category: selectedCategory,
              limit: 100,
            ),
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
                  return PostItem(post: posts[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
