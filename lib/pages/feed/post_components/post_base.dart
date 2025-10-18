import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../models/post_model.dart';
import '../../../controllers/post_controller.dart';
import '../../../widgets/rich_text_content.dart';
import '../../../widgets/url_link_preview.dart';
import '../../../widgets/safe_network_image.dart';
import 'post_detail_screen.dart';
import '../../../pages/profile/view_profile_page.dart';

class PostBase extends StatefulWidget {
  final PostModel post;
  final Widget? contentWidget;
  final bool isInDetailScreen;

  const PostBase({
    Key? key,
    required this.post,
    this.contentWidget,
    this.isInDetailScreen = false,
  }) : super(key: key);

  @override
  State<PostBase> createState() => _PostBaseState();
}

class _PostBaseState extends State<PostBase> {
  late PostModel post;
  late PostController _postController;
  String? _detectedUrl;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    // Get the post controller
    _postController = Get.find<PostController>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Only navigate to detail screen if not already in detail screen
        if (!widget.isInDetailScreen) {
          PostDetailScreen.show(context, post);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.only(left: 55.0),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichTextContent(
                        content: post.content,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        onUrlDetected: (url) {
                          if (_detectedUrl != url) {
                            setState(() {
                              _detectedUrl = url;
                            });
                          }
                        },
                      ),
                      // Show URL preview if URL is detected
                      if (_detectedUrl != null)
                        UrlLinkPreview(url: _detectedUrl!),
                      if (widget.contentWidget != null) ...[
                        const SizedBox(height: 12.0),
                        widget.contentWidget!,
                      ],
                    ],
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            _buildInteractionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _navigateToUserProfile(),
          child: SafeNetworkAvatar(
            imageUrl:
                post.userAvatar.isNotEmpty && post.userAvatar.startsWith('http')
                    ? post.userAvatar
                    : null,
            radius: 20.0,
            backgroundColor: const Color(0xFFEEF5FF),
            fallbackIcon: Icons.person,
            fallbackIconColor: const Color(0xFF5796FF),
            fallbackIconSize: 24,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: GestureDetector(
            onTap: () => _navigateToUserProfile(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.userName,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          color: Color(0xff333333),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        post.userHandle,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          color: Color(0xff333333),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      _formatPostTime(post.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12.0),
                    ),
                    const SizedBox(width: 16.0),
                    // University logo
                    if (post.universityLogo != null) ...[
                      _buildUniversityLogo(),
                      const SizedBox(width: 4.0),
                    ],
                    // University name (role)
                    Text(
                      post.userRole,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        IconButton(
          icon: const Icon(Icons.more_horiz),
          color: const Color(0xff28303F),
          onPressed: _showPostOptions,
          splashRadius: 20.0,
        ),
      ],
    );
  }

  Widget _buildInteractionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _wrapWithContainer(
          _buildInteractionButton(
            post.isLiked ? Icons.favorite : Icons.favorite_border,
            post.likes.toString(),
            iconColor: post.isLiked ? Colors.red : null,
            onTap: _handleLike,
          ),
        ),
        SizedBox(width: 20),
        _wrapWithContainer(
          _buildInteractionButton(
            Icons.comment_outlined,
            post.comments.toString(),
            onTap: _handleComment,
          ),
        ),
        SizedBox(width: 20),
        _wrapWithContainer(
          _buildInteractionButton(
            Icons.share_outlined,
            post.shares.toString(),
            onTap: _handleShare,
          ),
        ),
      ],
    );
  }

  Widget _wrapWithContainer(Widget child) {
    return Container(
      width: 85,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        color: const Color(0xffF0F0F0).withValues(alpha: 0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: child,
      ),
    );
  }

  void _handleLike() async {
    // Optimistic update for responsive UI
    setState(() {
      if (post.isLiked) {
        post.likes--;
        post.isLiked = false;
      } else {
        post.likes++;
        post.isLiked = true;
      }
    });

    try {
      // Call API in the background
      bool success;
      if (post.isLiked) {
        success = await _postController.likePost(post.id);
      } else {
        success = await _postController.unlikePost(post.id);
      }

      // If API call failed, revert the optimistic update
      if (!success) {
        setState(() {
          if (post.isLiked) {
            post.likes--;
            post.isLiked = false;
          } else {
            post.likes++;
            post.isLiked = true;
          }
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like status')),
        );
      }
    } catch (e) {
      print('Error handling like: $e');
    }
  }

  void _handleComment() {
    // Navigate to post details screen where comments can be made
    // Set focusCommentInput to true to trigger keyboard automatically
    if (!widget.isInDetailScreen) {
      PostDetailScreen.show(context, post, focusCommentInput: true);
    }
  }

  void _handleShare() {
    // Show share options
    setState(() {
      post.shares++;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post shared!')));
  }

  // Bookmark functionality - not currently used in UI
  // ignore: unused_element
  void _handleBookmark() async {
    // Optimistic update for responsive UI
    final wasBookmarked = post.isBookmarked;
    setState(() {
      post.isBookmarked = !wasBookmarked;
    });

    // Show feedback to user
    if (post.isBookmarked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Post saved to bookmarks')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post removed from bookmarks')),
      );
    }

    try {
      // Call API in the background
      bool success;
      if (post.isBookmarked) {
        success = await _postController.bookmarkPost(post.id);
      } else {
        success = await _postController.unbookmarkPost(post.id);
      }

      // If API call failed, revert the optimistic update
      if (!success) {
        setState(() {
          post.isBookmarked = wasBookmarked;
        });

        // Show error message
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update bookmark status')),
        );
      }
    } catch (e) {
      print('Error handling bookmark: $e');
    }
  }

  void _navigateToUserProfile() {
    // Navigate to the user profile screen
    ViewProfilePage.showProfile(context, post);
  }

  void _showPostOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('View ${post.userName}\'s profile'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToUserProfile();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_outlined),
                  title: const Text('Report post'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post reported')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text('Block user'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User blocked')),
                    );
                  },
                ),
                if (post.userId == '1') // Assuming '1' is the current user's ID
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete post'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post deleted')),
                      );
                      // Here you would call a callback to delete the post from the list
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String count, {
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon, size: 20.0, color: iconColor),
            onPressed: onTap,
            splashRadius: 20.0,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 2.0),
          Text(
            count,
            style: TextStyle(
              color: iconColor ?? Colors.grey[600],
              fontSize: 14.0,
            ),
          ),
          const SizedBox(width: 2.0), // Add space at the end as well
        ],
      ),
    );
  }

  Widget _buildUniversityLogo() {
    return SizedBox(
      width: 16,
      height: 16,
      child: Builder(
        builder: (context) {
          try {
            // Check if the logo is SVG or regular image
            if (post.universityLogo!.endsWith('.svg')) {
              return SvgPicture.asset(
                post.universityLogo!,
                width: 16,
                height: 16,
                placeholderBuilder:
                    (context) =>
                        Icon(Icons.school, size: 16, color: Colors.grey[600]),
              );
            } else {
              return Image.asset(
                post.universityLogo!,
                width: 16,
                height: 16,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.school, size: 16, color: Colors.grey[600]);
                },
              );
            }
          } catch (e) {
            // Fallback to a default icon if anything goes wrong
            return Icon(Icons.school, size: 16, color: Colors.grey[600]);
          }
        },
      ),
    );
  }

  String _formatPostTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
