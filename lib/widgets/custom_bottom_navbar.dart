import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

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
                // Center floating action button - elevated with higher z-index
                Positioned(
                  top: -45,
                  child: Material(
                    elevation: 8, // Adds material elevation for proper z-index
                    color:
                        Colors
                            .transparent, // Makes the material background transparent
                    shadowColor: const Color(
                      0x40000000,
                    ), // Shadow color matching the button
                    shape: const CircleBorder(), // Keeps the circular shape
                    child: GestureDetector(
                      onTap: () => onTap(2),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: Offset(0, 2),
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
              ],
            ),
          ),
          SizedBox(height: 16),
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
