import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../models/post_model.dart';

class PostComposition extends StatefulWidget {
  final Function(PostModel) onPostCreated;
  
  const PostComposition({
    Key? key,
    required this.onPostCreated,
  }) : super(key: key);

  static Future<void> show(BuildContext context, Function(PostModel) onPostCreated) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostComposition(onPostCreated: onPostCreated),
    );
  }

  @override
  State<PostComposition> createState() => _PostCompositionState();
}

class _PostCompositionState extends State<PostComposition> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isCreatingPost = false;
  bool _showLinkField = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContentField(),
            if (_showLinkField) _buildLinkField(),
            if (_selectedImages.isNotEmpty) _buildImagePreviews(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20.0,
          backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
        ),
        const SizedBox(width: 12.0),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text(
              'Share your thoughts',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: TextField(
        controller: _contentController,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: "What's on your mind?",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12.0),
        ),
      ),
    );
  }

  Widget _buildLinkField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: _linkController,
        decoration: const InputDecoration(
          hintText: "Enter a link",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(12.0),
          prefixIcon: Icon(Icons.link),
        ),
      ),
    );
  }

  Widget _buildImagePreviews() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: FileImage(_selectedImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 13,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            _buildActionButton(
              icon: Icons.image,
              label: 'Photo',
              onTap: _pickImage,
            ),
            _buildActionButton(
              icon: Icons.link,
              label: 'Link',
              onTap: () {
                setState(() {
                  _showLinkField = !_showLinkField;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isCreatingPost ? null : _createPost,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: _isCreatingPost
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey[700]),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _createPost() async {
    if (_contentController.text.isEmpty &&
        _selectedImages.isEmpty &&
        _linkController.text.isEmpty) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content to your post')),
      );
      return;
    }

    setState(() {
      _isCreatingPost = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Determine post type
    PostType postType;
    if (_linkController.text.isNotEmpty) {
      postType = PostType.link;
    } else if (_selectedImages.isNotEmpty) {
      postType = PostType.image;
    } else {
      postType = PostType.text;
    }

    // Create post object
    final newPost = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '1',
      userName: 'Current User',
      userAvatar: 'https://randomuser.me/api/portraits/men/1.jpg',
      userHandle: '@user',
      userRole: 'Student',
      content: _contentController.text,
      // In a real app, you would upload images to cloud storage
      images: _selectedImages.isNotEmpty ? ['assets/images/Group 13.png'] : [],
      createdAt: DateTime.now(),
      type: postType,
      link: _linkController.text.isEmpty ? null : _linkController.text,
    );

    // Call the callback
    widget.onPostCreated(newPost);

    // Close the sheet
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
