enum PostType { text, image, link }

// Content type from API
enum ContentType { Text, Image, Video, Link }

// Post audience type from API
enum PostAudience { Public, Private, Friends }

// Post type from API
enum ApiPostType { Original, Repost, Comment }

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String userHandle;
  final String userRole;
  final String? universityLogo; // University logo image path/URL
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
    this.universityLogo, // Optional university logo
    required this.content,
    this.images = const [],
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    required this.type,
    this.link,
  });

  // Convert API JSON response to PostModel - using simplified structure
  // We'll have to fill in missing fields with mock data for UI display
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Convert API content type to our app's PostType
    PostType getPostType(String? contentType) {
      switch (contentType) {
        case 'Image':
        case 'Video':
          return PostType.image;
        case 'Link':
          return PostType.link;
        case 'Text':
        default:
          return PostType.text;
      }
    }

    // Handle the case where media URLs could be a string or a list
    List<String> parseMediaUrls(dynamic mediaUrls) {
      if (mediaUrls == null) return [];

      if (mediaUrls is String) {
        return [mediaUrls];
      } else if (mediaUrls is List) {
        return mediaUrls.map((url) => url.toString()).toList();
      }

      return [];
    }

    // Generate a random ID if not present
    String id =
        json['id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    // Map API field names to our model field names
    String userId =
        json['creatorId']?.toString() ?? json['userId']?.toString() ?? 'user1';
    String userName = json['creatorName'] ?? json['userName'] ?? 'Campus User';
    String? userAvatar = json['creatorAvatar'] ?? json['userAvatar'];

    // Generate user handle from name or email if not provided
    String userHandle =
        json['userHandle'] ?? '@${userName.toLowerCase().replaceAll(' ', '')}';

    // Extract reaction/engagement counts
    int likes = json['reactionCount'] ?? json['likesCount'] ?? 0;
    int comments = json['commentCount'] ?? json['commentsCount'] ?? 0;
    int shares = json['repostCount'] ?? json['sharesCount'] ?? 0;

    return PostModel(
      // Use available fields from API
      id: id,
      userId: userId,
      userName: userName,
      // Use empty string as fallback instead of generating URL - UI will show icon
      userAvatar: userAvatar ?? '',
      userHandle: userHandle,
      userRole: json['userRole'] ?? 'Student',
      universityLogo: json['universityLogo'],
      content: json['content'] ?? '',
      images: parseMediaUrls(json['mediaUrls']),
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      likes: likes,
      comments: comments,
      shares: shares,
      type: getPostType(json['contentType']),
      link: json['link'],
    );
  }

  // Convert to JSON for API requests - simplified structure as per requirements
  Map<String, dynamic> toJson() {
    String getContentType() {
      switch (type) {
        case PostType.image:
          return images.isNotEmpty ? 'Image' : 'Text';
        case PostType.link:
          return 'Link';
        case PostType.text:
          return 'Text';
      }
    }

    return {
      'content': content,
      'contentType': getContentType(),
      'mediaUrls': images,
      'audience': 'Public',
      'parentId': 0, // Default to 0 for non-replies
      'postType': 'Original',
    };
  }

  // Create a mock post for testing
  factory PostModel.mockText() {
    return PostModel(
      id: '1',
      userId: '1',
      userName: 'Victory Ekpenyong',
      userAvatar: 'https://randomuser.me/api/portraits/women/1.jpg',
      userHandle: '@VickyEK',
      userRole: 'Computer Science',
      universityLogo: 'assets/university_icon.png',
      content:
          'Lorem ipsum dolor sit amet consectetur. Molestie vulputate lobortis id eu nisi est.',
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
      universityLogo: 'assets/university_icon.png',
      content:
          'Lorem ipsum dolor sit amet consectetur. Molestie vulputate lobortis id eu nisi est.',
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
      universityLogo: 'assets/university_icon.png',
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
