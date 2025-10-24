class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final List<String>? attachments;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    this.type = MessageType.text,
    required this.timestamp,
    this.isRead = false,
    this.attachments,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      senderAvatar: json['senderAvatar'],
      message: json['message'] ?? '',
      type: _parseMessageType(json['type']),
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      isRead: json['isRead'] ?? false,
      attachments:
          json['attachments'] != null
              ? List<String>.from(json['attachments'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachments': attachments,
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? message,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    List<String>? attachments,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      attachments: attachments ?? this.attachments,
    );
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.text;

    switch (type.toString().toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      case 'location':
        return MessageType.location;
      default:
        return MessageType.text;
    }
  }
}

enum MessageType { text, image, file, audio, video, location }
