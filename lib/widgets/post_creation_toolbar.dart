import 'package:flutter/material.dart';
import '../pages/post/create_post_page.dart';
import '../pages/project/create_project_page.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PostCreationToolbar extends StatelessWidget {
  final bool isProject;
  final VoidCallback onHashtagPressed;
  final VoidCallback onMentionPressed;
  final VoidCallback onImagePressed;
  final VoidCallback onAddPressed;
  final VoidCallback? onThreadPressed; // New callback for thread creation
  final int threadCount; // Number of threads currently present

  const PostCreationToolbar({
    Key? key,
    this.isProject = false,
    required this.onHashtagPressed,
    required this.onMentionPressed,
    required this.onImagePressed,
    required this.onAddPressed,
    this.onThreadPressed,
    this.threadCount = 0,
  }) : super(key: key);

  void _showCreateTypeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Create Post Option
              _buildCreateTypeOption(
                context,
                'Create post',
                Icons.article_outlined,
                !isProject, // Selected if we're in post creation
                () {
                  Navigator.pop(context); // Close bottom sheet
                  if (isProject) {
                    // Navigate to post creation page if we're in project page
                    Get.off(() => const CreatePostPage());
                  }
                },
              ),
              const SizedBox(height: 16),
              // Create Project Option
              _buildCreateTypeOption(
                context,
                'Create project',
                Icons.lightbulb_outline,
                isProject, // Selected if we're in project creation
                () {
                  Navigator.pop(context); // Close bottom sheet
                  if (!isProject) {
                    // Navigate to project creation page if we're in post page
                    Get.off(() => const CreateProjectPage());
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateTypeOption(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFF4F4F4),
              radius: 24,
              child: Icon(icon, color: const Color(0xFF333333), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xffF9FAFB)),
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 98, top: 12),
      child: Row(
        children: [
          // Post/Project Type Selection Button
          GestureDetector(
            onTap: () => _showCreateTypeSelector(context),
            child: Container(
              child: Row(
                children: [
                  Text(
                    isProject ? 'Project' : 'Post',
                    style: const TextStyle(
                      color: Color(0xff333333),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xff333333),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Action Icons
          IconButton(
            icon: const Icon(Icons.tag, color: Color(0xff5796FF)),
            onPressed: onHashtagPressed,
          ),
          IconButton(
            icon: const Icon(Icons.alternate_email, color: Color(0xff5796FF)),
            onPressed: onMentionPressed,
          ),
          IconButton(
            icon: const Icon(Icons.image, color: Color(0xff5796FF)),
            onPressed: onImagePressed,
          ),
          // Thread button with count (only show if onThreadPressed is provided)
          if (onThreadPressed != null)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xff5796FF)),
                  onPressed: onThreadPressed,
                  tooltip: 'Add thread post',
                ),
                if (threadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$threadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xff5796FF)),
              onPressed: onAddPressed,
              tooltip: 'Add',
            ),
        ],
      ),
    );
  }
}
