import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import 'post_base.dart';

class ImagePost extends StatelessWidget {
  final PostModel post;
  
  const ImagePost({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PostBase(
      post: post,
      contentWidget: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    if (post.images.isEmpty) {
      return const SizedBox.shrink();
    }

    // If only one image, show it full width
    if (post.images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          post.images[0],
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    }

    // If multiple images, show them in a grid
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: post.images.length > 2 ? 3 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: post.images.length > 4 ? 4 : post.images.length, // Limit to 4 images
      itemBuilder: (context, index) {
        // If there are more than 4 images, the 4th thumbnail shows a +X overlay
        if (index == 3 && post.images.length > 4) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  post.images[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.6),
                ),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Text(
                    '+${post.images.length - 3}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            post.images[index],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
