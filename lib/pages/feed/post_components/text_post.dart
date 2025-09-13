import 'package:flutter/material.dart';
import '../../../models/post_model.dart';
import 'post_base.dart';

class TextPost extends StatelessWidget {
  final PostModel post;
  
  const TextPost({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For text posts, we don't need additional content widget beyond what's in the base
    return PostBase(post: post);
  }
}
