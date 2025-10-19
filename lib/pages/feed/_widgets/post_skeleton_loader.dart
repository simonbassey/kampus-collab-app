import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostSkeletonLoader extends StatelessWidget {
  const PostSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Avatar and user info
            Row(
              children: [
                // Avatar
                CircleAvatar(radius: 20.0, backgroundColor: Colors.grey[300]),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Time and role
                      Container(
                        width: 180,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // Post content
            Padding(
              padding: const EdgeInsets.only(left: 55.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content lines
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    width: 200,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            // Interaction bar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSkeletonButton(),
                const SizedBox(width: 20),
                _buildSkeletonButton(),
                const SizedBox(width: 20),
                _buildSkeletonButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonButton() {
    return Container(
      width: 85,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey[300],
      ),
    );
  }
}

class PostSkeletonLoaderList extends StatelessWidget {
  final int itemCount;

  const PostSkeletonLoaderList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const PostSkeletonLoader(),
    );
  }
}
