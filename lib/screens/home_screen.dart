import 'package:dak_louk/widgets/category_bar.dart';
import 'package:dak_louk/widgets/post_block.dart';
import 'package:dak_louk/db/dao/post_dao.dart';
import 'package:dak_louk/models/post_model.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        CategoryBar(),
        const SizedBox(height: 16.0),
        Expanded(
          child: FutureBuilder<List<Post>>(
            future: PostDao().getAllPosts(),
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
