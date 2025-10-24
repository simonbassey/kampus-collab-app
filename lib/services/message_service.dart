import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../constants/api.dart';
import 'auth_service.dart';

class MessageService {
  final AuthService _authService = AuthService();

  // Get all conversations for the current user
  Future<List<ConversationModel>> getConversations() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/messages/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GET Conversations Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conversations =
            (data['conversations'] as List)
                .map((json) => ConversationModel.fromJson(json))
                .toList();

        debugPrint(
          'MessageService: Loaded ${conversations.length} conversations',
        );
        return conversations;
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MessageService: Error getting conversations - $e');
      rethrow;
    }
  }

  // Get messages for a specific conversation
  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/messages/conversations/$conversationId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GET Messages Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages =
            (data['messages'] as List)
                .map((json) => MessageModel.fromJson(json))
                .toList();

        debugPrint('MessageService: Loaded ${messages.length} messages');
        return messages;
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MessageService: Error getting messages - $e');
      rethrow;
    }
  }

  // Send a message
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String message,
    MessageType type = MessageType.text,
    List<String>? attachments,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = {
        'conversationId': conversationId,
        'message': message,
        'type': type.toString().split('.').last,
        if (attachments != null) 'attachments': attachments,
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint('POST Message Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final newMessage = MessageModel.fromJson(data);

        debugPrint('MessageService: Message sent successfully');
        return newMessage;
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MessageService: Error sending message - $e');
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse(
          '${ApiConstants.baseUrl}/messages/conversations/$conversationId/read',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('PUT Mark as Read Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('MessageService: Error marking as read - $e');
      rethrow;
    }
  }

  // Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse(
          '${ApiConstants.baseUrl}/messages/conversations/$conversationId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('DELETE Conversation Response Status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete conversation: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('MessageService: Error deleting conversation - $e');
      rethrow;
    }
  }

  // Create a new conversation
  Future<ConversationModel> createConversation({
    required String userId,
    String? initialMessage,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = {
        'userId': userId,
        if (initialMessage != null) 'message': initialMessage,
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/messages/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint(
        'POST Create Conversation Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final conversation = ConversationModel.fromJson(data);

        debugPrint('MessageService: Conversation created successfully');
        return conversation;
      } else {
        throw Exception(
          'Failed to create conversation: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('MessageService: Error creating conversation - $e');
      rethrow;
    }
  }
}
