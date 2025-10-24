import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_bottom_navbar.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedView = 'Inbox'; // 'Inbox' or 'Projects'

  // Mock data - will be replaced with real data from backend
  final List<Conversation> _conversations = [
    Conversation(
      id: '1',
      userName: 'Precious Eyo',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      lastMessage: 'Good day, what\'s the price?',
      timestamp: DateTime.now().subtract(Duration(minutes: 32)),
      unreadCount: 0,
      isOnline: false,
    ),
    Conversation(
      id: '2',
      userName: 'Mary Okon',
      userAvatar: 'https://i.pravatar.cc/150?img=2',
      lastMessage: 'Good day, what\'s the price?',
      timestamp: DateTime.now().subtract(Duration(minutes: 32)),
      unreadCount: 2,
      isOnline: false,
    ),
    Conversation(
      id: '3',
      userName: 'Precious Eyo',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      lastMessage: 'Good day, what\'s the price?',
      timestamp: DateTime.now().subtract(Duration(minutes: 32)),
      unreadCount: 0,
      isOnline: false,
    ),
    Conversation(
      id: '4',
      userName: 'Precious Eyo',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      lastMessage: 'Good day, what\'s the price?',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      unreadCount: 0,
      isOnline: false,
    ),
    Conversation(
      id: '5',
      userName: 'Precious Eyo',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      lastMessage: 'Good day, what\'s the price?',
      timestamp: DateTime.now().subtract(Duration(minutes: 32)),
      unreadCount: 0,
      isOnline: false,
    ),
    Conversation(
      id: '6',
      userName: 'Precious Eyo',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      lastMessage: 'Good day, what\'s the price?',
      timestamp: DateTime(2024, 12, 23),
      unreadCount: 0,
      isOnline: false,
    ),
    Conversation(
      id: '7',
      userName: 'Precious Eyo',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      lastMessage: 'Good day, what\'s the price?',
      timestamp: DateTime.now().subtract(Duration(minutes: 32)),
      unreadCount: 0,
      isOnline: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: _handleNavigation,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildAppBar(),

            // Search bar
            _buildSearchBar(),

            // Conversations list
            Expanded(
              child: _buildConversationsList(
                _selectedView == 'Inbox'
                    ? _conversations
                    : _getProjectConversations(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Inbox',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Color(0xFF333333),
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.more_vert, color: Color(0xFF333333)),
            onPressed: () {
              _showViewOptions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
          prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
          filled: true,
          fillColor: Color(0xFFF3F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildConversationsList(List<Conversation> conversations) {
    if (conversations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        return _buildConversationItem(conversations[index]);
      },
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    return InkWell(
      onTap: () {
        // Navigate to chat screen
        Get.to(() => ChatScreen(
          conversation: conversation,
          isProjectChat: _selectedView == 'Projects',
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(conversation.userAvatar),
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint('Error loading avatar: $exception');
              },
              backgroundColor: Color(0xFF5796FF).withOpacity(0.2),
            ),
            SizedBox(width: 16),
            // Conversation details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.userName,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Color(0xFF5796FF),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${conversation.unreadCount}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            // Timestamp
            Text(
              _formatTimestamp(conversation.timestamp),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Color(0xFFE5E7EB)),
          SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start a conversation with your\nclassmates and colleagues',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  void _handleNavigation(int index) {
    if (index == 0) {
      Get.back(); // Go back to feed
    }
    // Other navigation will be handled by parent
  }

  void _showViewOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.inbox, color: Color(0xFF333333)),
                    title: Text(
                      'Inbox',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing:
                        _selectedView == 'Inbox'
                            ? Icon(Icons.check, color: Colors.green)
                            : null,
                    onTap: () {
                      setState(() {
                        _selectedView = 'Inbox';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.group, color: Color(0xFF333333)),
                    title: Text(
                      'Projects',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing:
                        _selectedView == 'Projects'
                            ? Icon(Icons.check, color: Colors.green)
                            : null,
                    onTap: () {
                      setState(() {
                        _selectedView = 'Projects';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  List<Conversation> _getProjectConversations() {
    // Mock project conversations (group chats)
    return [
      Conversation(
        id: 'p1',
        userName: 'Mobile App Development',
        userAvatar: 'https://i.pravatar.cc/150?img=3',
        lastMessage: 'Let\'s discuss the UI design for the login screen',
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        unreadCount: 3,
        isOnline: false,
      ),
      Conversation(
        id: 'p2',
        userName: 'Web Development Team',
        userAvatar: 'https://i.pravatar.cc/150?img=4',
        lastMessage: 'The API integration is complete',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        unreadCount: 0,
        isOnline: false,
      ),
      Conversation(
        id: 'p3',
        userName: 'Data Science Project',
        userAvatar: 'https://i.pravatar.cc/150?img=5',
        lastMessage: 'Model training results look promising',
        timestamp: DateTime.now().subtract(Duration(hours: 5)),
        unreadCount: 1,
        isOnline: false,
      ),
      Conversation(
        id: 'p4',
        userName: 'UI/UX Design Team',
        userAvatar: 'https://i.pravatar.cc/150?img=6',
        lastMessage: 'New mockups are ready for review',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        unreadCount: 0,
        isOnline: false,
      ),
    ];
  }
}

// Model for conversation
class Conversation {
  final String id;
  final String userName;
  final String userAvatar;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;

  Conversation({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
  });
}
