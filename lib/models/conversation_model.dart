class ConversationModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;
  final ConversationType type;

  ConversationModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
    this.type = ConversationType.direct,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown',
      userAvatar: json['userAvatar'],
      lastMessage: json['lastMessage'] ?? '',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      type:
          json['type'] == 'group'
              ? ConversationType.group
              : ConversationType.direct,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'lastMessage': lastMessage,
      'timestamp': timestamp.toIso8601String(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'type': type == ConversationType.group ? 'group' : 'direct',
    };
  }

  ConversationModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? lastMessage,
    DateTime? timestamp,
    int? unreadCount,
    bool? isOnline,
    ConversationType? type,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      type: type ?? this.type,
    );
  }
}

enum ConversationType { direct, group }
