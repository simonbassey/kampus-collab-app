import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import 'text_post.dart';
import 'image_post.dart';
import 'link_post.dart';

class PostList extends StatelessWidget {
  final List<PostModel> posts;
  final bool isLoading;
  final Function()? onRefresh;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const PostList({
    Key? key,
    required this.posts,
    this.isLoading = false,
    this.onRefresh,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return const Center(child: Text('No posts to display'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (onRefresh != null) {
          onRefresh!();
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: posts.length,
        separatorBuilder:
            (context, index) => Divider(
              color: const Color(0xFFF0F0F0),
              height: 1,
              thickness: 1,
            ),
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostByType(post);
        },
      ),
    );
  }

  Widget _buildPostByType(PostModel post) {
    switch (post.type) {
      case PostType.text:
        return TextPost(post: post);
      case PostType.image:
        return ImagePost(post: post);
      case PostType.link:
        return LinkPost(post: post);
      default:
        return TextPost(post: post);
    }
  }
}
