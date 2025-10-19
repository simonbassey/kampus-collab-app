import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../pages/post/create_post_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bottom navigation section
          Container(
            height: 90, // Increased height for better FAB visibility
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Stack(
              clipBehavior:
                  Clip.none, // Prevents clipping of positioned elements
              alignment: Alignment.topCenter,
              children: [
                // Navigation items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      svgPath: _getHomeSvg(),
                      label: 'Home',
                      isActive: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _buildNavItem(
                      index: 1,
                      svgPath: _getInboxSvg(),
                      label: 'Inbox',
                      isActive: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                    const SizedBox(width: 40), // Space for FAB
                    _buildNavItem(
                      index: 3,
                      svgPath: _getVaultSvg(),
                      label: 'Vault',
                      isActive: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                    _buildNavItem(
                      index: 4,
                      svgPath: _getNotificationSvg(),
                      label: 'Notification',
                      isActive: currentIndex == 4,
                      onTap: () => onTap(4),
                    ),
                  ],
                ),
                // Center floating action button with improved tap area
                Positioned(
                  top: -45,
                  child: GestureDetector(
                    // This ensures the entire area is tappable
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      // Open the create post page
                      Get.to(() => const CreatePostPage());
                    },
                    // Create a larger invisible tap area
                    child: Container(
                      width:
                          80, // Larger than the visible button for better tapping
                      height:
                          80, // Larger than the visible button for better tapping
                      color: Colors.transparent, // Invisible container
                      alignment: Alignment.center,
                      child: Material(
                        elevation: 8,
                        color: Colors.transparent,
                        shadowColor: const Color(0x40000000),
                        shape: const CircleBorder(),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90E2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String svgPath,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 69,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isActive ? const Color(0xFF4A90E2) : Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? const Color(0xFF4A90E2) : Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHomeSvg() {
    return 'assets/icons/home.svg';
  }

  String _getInboxSvg() {
    return 'assets/icons/inbox.svg';
  }

  String _getVaultSvg() {
    return 'assets/icons/vault.svg';
  }

  String _getNotificationSvg() {
    return 'assets/icons/notification.svg';
  }
}
