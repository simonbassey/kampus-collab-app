import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class MessageController extends GetxController {
  final MessageService _messageService = MessageService();

  // Observable state
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxMap<String, List<MessageModel>> messagesMap =
      <String, List<MessageModel>>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
  }

  // Load all conversations
  Future<void> loadConversations() async {
    try {
      isLoading.value = true;
      error.value = '';

      final result = await _messageService.getConversations();
      conversations.value = result;
    } catch (e) {
      error.value = 'Failed to load conversations: $e';
      debugPrint('MessageController: Error loading conversations - $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load messages for a specific conversation
  Future<void> loadMessages(String conversationId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final messages = await _messageService.getMessages(conversationId);
      messagesMap[conversationId] = messages;
    } catch (e) {
      error.value = 'Failed to load messages: $e';
      debugPrint('MessageController: Error loading messages - $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Send a message
  Future<bool> sendMessage({
    required String conversationId,
    required String message,
    MessageType type = MessageType.text,
    List<String>? attachments,
  }) async {
    try {
      final newMessage = await _messageService.sendMessage(
        conversationId: conversationId,
        message: message,
        type: type,
        attachments: attachments,
      );

      // Add message to local list
      if (messagesMap.containsKey(conversationId)) {
        messagesMap[conversationId]!.add(newMessage);
        messagesMap.refresh();
      }

      // Update conversation's last message
      final conversationIndex = conversations.indexWhere(
        (c) => c.id == conversationId,
      );
      if (conversationIndex != -1) {
        conversations[conversationIndex] = conversations[conversationIndex]
            .copyWith(lastMessage: message, timestamp: DateTime.now());
      }

      return true;
    } catch (e) {
      error.value = 'Failed to send message: $e';
      debugPrint('MessageController: Error sending message - $e');
      return false;
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String conversationId) async {
    try {
      await _messageService.markAsRead(conversationId);

      // Update local conversation
      final conversationIndex = conversations.indexWhere(
        (c) => c.id == conversationId,
      );
      if (conversationIndex != -1) {
        conversations[conversationIndex] = conversations[conversationIndex]
            .copyWith(unreadCount: 0);
      }

      // Update local messages
      if (messagesMap.containsKey(conversationId)) {
        messagesMap[conversationId] =
            messagesMap[conversationId]!
                .map((m) => m.copyWith(isRead: true))
                .toList();
      }
    } catch (e) {
      debugPrint('MessageController: Error marking as read - $e');
    }
  }

  // Delete a conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      await _messageService.deleteConversation(conversationId);
      conversations.removeWhere((c) => c.id == conversationId);
      messagesMap.remove(conversationId);
      return true;
    } catch (e) {
      error.value = 'Failed to delete conversation: $e';
      debugPrint('MessageController: Error deleting conversation - $e');
      return false;
    }
  }

  // Get unread count
  int get totalUnreadCount {
    return conversations.fold(
      0,
      (sum, conversation) => sum + conversation.unreadCount,
    );
  }

  // Search conversations
  List<ConversationModel> searchConversations(String query) {
    if (query.isEmpty) return conversations;

    return conversations.where((conversation) {
      return conversation.userName.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          conversation.lastMessage.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get messages for a conversation
  List<MessageModel> getMessages(String conversationId) {
    return messagesMap[conversationId] ?? [];
  }
}
