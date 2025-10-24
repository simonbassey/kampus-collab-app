import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'inbox_screen.dart';
import 'project_info_screen.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final bool isProjectChat;

  const ChatScreen({
    super.key, 
    required this.conversation,
    this.isProjectChat = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _hasText = false;
  bool _emojiPickerVisible = false;

  // Mock messages - will be replaced with real data from backend
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      senderId: 'other',
      message: 'Hello Isaiah',
      timestamp: DateTime.now().subtract(Duration(minutes: 1)),
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'me',
          message: _messageController.text.trim(),
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
    });

    _messageController.clear();

    // Scroll to bottom after sending message
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _startVoiceRecording() {
    // TODO: Implement voice recording functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voice recording feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Media attachment methods
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _sendImageMessage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _sendImageMessage(File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(minutes: 5),
      );

      if (video != null) {
        _sendVideoMessage(File(video.path));
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick video: $e');
    }
  }

  void _recordAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Audio recording feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pickDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document picker feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location sharing feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareContact() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact sharing feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _createPoll() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Poll creation feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _searchGif() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('GIF search feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sendImageMessage(File imageFile) {
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'me',
          message: '[Image]',
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
    });

    // Scroll to bottom after sending message
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image sent successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sendVideoMessage(File videoFile) {
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'me',
          message: '[Video]',
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
    });

    // Scroll to bottom after sending message
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Video sent successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showEmojiPicker() {
    setState(() {
      _emojiPickerVisible = !_emojiPickerVisible;
    });
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    final text = _messageController.text;
    final selection = _messageController.selection;

    // Ensure valid selection indices
    final start = selection.start >= 0 ? selection.start : 0;
    final end = selection.end >= 0 ? selection.end : 0;

    final newText = text.replaceRange(start, end, emoji.emoji);
    _messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.emoji.length),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) => _onEmojiSelected(category, emoji),
        config: Config(
          columns: 7,
          emojiSizeMax: 32.0,
          verticalSpacing: 0,
          horizontalSpacing: 0,
          initCategory: Category.SMILEYS,
          bgColor: Colors.white,
          indicatorColor: Color(0xFF5796FF),
          iconColor: Color(0xFF9CA3AF),
          iconColorSelected: Color(0xFF5796FF),
          backspaceColor: Color(0xFF5796FF),
          recentsLimit: 28,
          noRecents: Text(
            'No Recents',
            style: TextStyle(fontSize: 20, color: Color(0xFF9CA3AF)),
            textAlign: TextAlign.center,
          ),
          tabIndicatorAnimDuration: kTabScrollDuration,
          categoryIcons: const CategoryIcons(),
          buttonMode: ButtonMode.MATERIAL,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Divider after AppBar
          Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Message input
          _buildMessageInput(),

          // Emoji picker
          if (_emojiPickerVisible) _buildEmojiPicker(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF4F89E8)),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(widget.conversation.userAvatar),
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Error loading avatar: $exception');
            },
            backgroundColor: Color(0xFF5796FF).withValues(alpha: 0.2),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${widget.conversation.userName.toLowerCase().replaceAll(' ', '_')}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  'UNICROSS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Color(0xFF333333)),
          onPressed: () {
            _showMoreOptions();
          },
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == 'me';

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.conversation.userAvatar),
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Error loading avatar: $exception');
                },
                backgroundColor: Color(0xFF5796FF).withValues(alpha: 0.2),
              ),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Color(0xFF5796FF) : Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: isMe ? Colors.white : Color(0xFF333333),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color:
                          isMe
                              ? Colors.white.withValues(alpha: 0.7)
                              : Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showEmojiPicker,
                      child: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => _sendMessage(),
                        onTap: () {
                          if (_emojiPickerVisible) {
                            setState(() {
                              _emojiPickerVisible = false;
                            });
                          }
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAttachmentOptions,
                      child: Icon(
                        Icons.add,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              child: IconButton(
                icon: Icon(
                  _hasText ? Icons.send : Icons.mic,
                  color: Colors.white,
                ),
                onPressed: _hasText ? _sendMessage : _startVoiceRecording,
                style: IconButton.styleFrom(
                  backgroundColor: Color(0xFF5796FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.isProjectChat 
                ? _buildProjectOptions() 
                : _buildPersonalChatOptions(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProjectOptions() {
    return [
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
        leading: Icon(
          Icons.info_outline,
          color: Color(0xFF333333),
        ),
        title: Text(
          'Project Info',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        onTap: () {
          Navigator.pop(context);
          Get.to(() => ProjectInfoScreen(conversation: widget.conversation));
        },
      ),
      ListTile(
        leading: Icon(
          Icons.exit_to_app,
          color: Colors.red,
        ),
        title: Text(
          'Exit Group',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.red,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          _showExitGroupDialog();
        },
      ),
    ];
  }

  List<Widget> _buildPersonalChatOptions() {
    return [
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
        leading: Icon(
          Icons.person_outline,
          color: Color(0xFF333333),
        ),
        title: Text(
          'View Profile',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        onTap: () {
          Navigator.pop(context);
          // Navigate to profile
        },
      ),
      ListTile(
        leading: Icon(
          Icons.notifications_off_outlined,
          color: Color(0xFF333333),
        ),
        title: Text(
          'Mute Notifications',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.search, color: Color(0xFF333333)),
        title: Text(
          'Search in Conversation',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.block_outlined, color: Colors.red),
        title: Text(
          'Block User',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.red,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: Icon(Icons.delete_outline, color: Colors.red),
        title: Text(
          'Delete Conversation',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.red,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ];
  }

  void _showExitGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Exit Group',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to exit this project group? You won\'t be able to see new messages.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back(); // Go back to inbox
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('You have left the project group'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Exit',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Share',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Scrollable grid
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9,
                        children: [
                          _buildAttachmentOption(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            color: Color(0xFF8B5CF6),
                            onTap: _pickImageFromGallery,
                            isImplemented: true,
                          ),
                          _buildAttachmentOption(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            color: Color(0xFFEC4899),
                            onTap: _pickImageFromCamera,
                            isImplemented: true,
                          ),
                          _buildAttachmentOption(
                            icon: Icons.videocam,
                            label: 'Video',
                            color: Color(0xFFEF4444),
                            onTap: _pickVideo,
                            isImplemented: true,
                          ),
                          _buildAttachmentOption(
                            icon: Icons.audiotrack,
                            label: 'Audio',
                            color: Color(0xFF8B5CF6),
                            onTap: _recordAudio,
                            isImplemented: false,
                          ),
                          _buildAttachmentOption(
                            icon: Icons.insert_drive_file,
                            label: 'Document',
                            color: Color(0xFF3B82F6),
                            onTap: _pickDocument,
                            isImplemented: false,
                          ),
                          _buildAttachmentOption(
                            icon: Icons.location_on,
                            label: 'Location',
                            color: Color(0xFF10B981),
                            onTap: _shareLocation,
                            isImplemented: false,
                          ),
                          _buildAttachmentOption(
                            icon: Icons.person,
                            label: 'Contact',
                            color: Color(0xFFF59E0B),
                            onTap: _shareContact,
                            isImplemented: false,
                          ),
                          _buildAttachmentOption(
                            icon: Icons.poll,
                            label: 'Poll',
                            color: Color(0xFF06B6D4),
                            onTap: _createPoll,
                            isImplemented: false,
                          ),
                          _buildAttachmentOption(
                            icon: Icons.gif,
                            label: 'GIF',
                            color: Color(0xFFEC4899),
                            onTap: _searchGif,
                            isImplemented: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isImplemented = true,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              if (!isImplemented)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFF5796FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

// Model for chat message
class ChatMessage {
  final String id;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}
