import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfilePhotoViewer extends StatelessWidget {
  final dynamic photoData; // Can be Uint8List or String (asset path)
  final bool isAssetImage;

  const ProfilePhotoViewer({
    Key? key,
    required this.photoData,
    this.isAssetImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Photo
          Hero(
            tag: 'profile-photo-hero',
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF5796FF), width: 3),
                  image:
                      isAssetImage
                          ? DecorationImage(
                            image: AssetImage(photoData as String),
                            fit: BoxFit.cover,
                          )
                          : DecorationImage(
                            image: MemoryImage(photoData as Uint8List),
                            fit: BoxFit.cover,
                          ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
