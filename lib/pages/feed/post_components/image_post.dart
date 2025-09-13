import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import 'post_base.dart';
import 'image_viewer.dart';

class ImagePost extends StatelessWidget {
  final PostModel post;
  final BuildContext? contextOverride;
  final bool isInDetailScreen;

  ImagePost({Key? key, required this.post, this.contextOverride, this.isInDetailScreen = false})
    : super(key: key);

  BuildContext _getContext() {
    // This is a workaround to access context for showing dialogs from a stateless widget
    if (contextOverride != null) return contextOverride!;
    final context = _contextHolder.currentContext;
    if (context == null) throw Exception('Context is not available');
    return context;
  }

  // Context holder
  final GlobalKey _contextHolder = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return PostBase(post: post, contentWidget: _buildImageContent(), isInDetailScreen: isInDetailScreen);
  }

  Widget _buildImageContent() {
    if (post.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(key: _contextHolder, child: _buildImages());
  }

  Widget _buildImages() {
    if (post.images.isEmpty) {
      return const SizedBox.shrink();
    }

    // If only one image, show it full width
    if (post.images.length == 1) {
      return GestureDetector(
        onTap: () {
          ImageViewer.show(_getContext(), post.images[0], isAsset: true);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            post.images[0],
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
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
      itemCount:
          post.images.length > 4 ? 4 : post.images.length, // Limit to 4 images
      itemBuilder: (context, index) {
        // If there are more than 4 images, the 4th thumbnail shows a +X overlay
        if (index == 3 && post.images.length > 4) {
          return GestureDetector(
            onTap: () {
              _showImageGallery(post.images, index);
            },
            child: Stack(
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
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            _showImageGallery(post.images, index);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              post.images[index],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  void _showImageGallery(List<String> images, int initialIndex) {
    ImageViewer.show(_getContext(), images[initialIndex], isAsset: true);
  }
}
