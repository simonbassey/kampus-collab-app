import 'package:flutter/material.dart';

enum PostType {
  text,
  image,
  link,
}

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String userHandle;
  final String userRole;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  int likes;
  int comments;
  int shares;
  final PostType type;
  final String? link;
  bool isLiked = false;
  bool isBookmarked = false;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.userHandle,
    required this.userRole,
    required this.content,
    this.images = const [],
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.type,
    this.link,
  });

  // Create a mock post for testing
  factory PostModel.mockText() {
    return PostModel(
      id: '1',
      userId: '1',
      userName: 'Victory Ekpenyong',
      userAvatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      userHandle: '@VickyEK',
      userRole: 'Computer Science',
      content: 'Lorem ipsum dolor sit amet consectetur. Molestie vulputate lobortis id eu nisi est.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 0,
      comments: 0,
      shares: 0,
      type: PostType.text,
    );
  }

  factory PostModel.mockImage() {
    return PostModel(
      id: '2',
      userId: '1',
      userName: 'Victory Ekpenyong',
      userAvatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      userHandle: '@VickyEK',
      userRole: 'Computer Science',
      content: 'Lorem ipsum dolor sit amet consectetur. Molestie vulputate lobortis id eu nisi est.',
      images: ['assets/images/Group 13.png', 'assets/images/Group 13.png'],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      likes: 0,
      comments: 0,
      shares: 0,
      type: PostType.image,
    );
  }
  
  factory PostModel.mockLink() {
    return PostModel(
      id: '3',
      userId: '1',
      userName: 'Victory Ekpenyong',
      userAvatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      userHandle: '@VickyEK',
      userRole: 'Computer Science',
      content: 'Check out this great resource for Flutter development!',
      images: ['assets/images/Group 13.png'],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      likes: 0,
      comments: 0,
      shares: 0,
      type: PostType.link,
      link: 'https://flutter.dev/docs/get-started/codelab',
    );
  }
}
