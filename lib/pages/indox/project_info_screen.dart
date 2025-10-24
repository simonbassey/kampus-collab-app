import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'inbox_screen.dart';

class ProjectInfoScreen extends StatefulWidget {
  final Conversation conversation;

  const ProjectInfoScreen({super.key, required this.conversation});

  @override
  State<ProjectInfoScreen> createState() => _ProjectInfoScreenState();
}

class _ProjectInfoScreenState extends State<ProjectInfoScreen> {
  // Mock project members data
  final List<ProjectMember> _members = [
    ProjectMember(
      id: '1',
      name: 'Isaiah Okon',
      avatar: 'https://i.pravatar.cc/150?img=1',
      role: 'Project Lead',
      isOnline: true,
    ),
    ProjectMember(
      id: '2',
      name: 'Mary Johnson',
      avatar: 'https://i.pravatar.cc/150?img=2',
      role: 'Developer',
      isOnline: false,
    ),
    ProjectMember(
      id: '3',
      name: 'David Smith',
      avatar: 'https://i.pravatar.cc/150?img=3',
      role: 'Designer',
      isOnline: true,
    ),
    ProjectMember(
      id: '4',
      name: 'Sarah Wilson',
      avatar: 'https://i.pravatar.cc/150?img=4',
      role: 'Developer',
      isOnline: false,
    ),
    ProjectMember(
      id: '5',
      name: 'Michael Brown',
      avatar: 'https://i.pravatar.cc/150?img=5',
      role: 'Tester',
      isOnline: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Project Header
            _buildProjectHeader(),
            
            // Divider
            Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            
            // Project Details
            _buildProjectDetails(),
            
            // Members Section
            _buildMembersSection(),
          ],
        ),
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
      title: Text(
        'Project Info',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
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

  Widget _buildProjectHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Project Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF5796FF).withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                widget.conversation.userAvatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.group,
                    size: 50,
                    color: Color(0xFF5796FF),
                  );
                },
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Project Name
          Text(
            widget.conversation.userName,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 8),
          
          // Project Description
          Text(
            'A collaborative project for building innovative solutions',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 16),
          
          // Project Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Members', '${_members.length}'),
              _buildStatItem('Created', 'Oct 15, 2024'),
              _buildStatItem('Status', 'Active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDetails() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          
          SizedBox(height: 16),
          
          _buildDetailItem(
            icon: Icons.category_outlined,
            title: 'Category',
            value: 'Mobile Development',
          ),
          
          _buildDetailItem(
            icon: Icons.schedule_outlined,
            title: 'Duration',
            value: '3 months',
          ),
          
          _buildDetailItem(
            icon: Icons.school_outlined,
            title: 'Course',
            value: 'Software Engineering',
          ),
          
          _buildDetailItem(
            icon: Icons.location_on_outlined,
            title: 'Institution',
            value: 'UNICROSS',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF5796FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Color(0xFF5796FF),
              size: 20,
            ),
          ),
          
          SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${_members.length})',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Add member functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Add member feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  'Add',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5796FF),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _members.length,
            itemBuilder: (context, index) {
              return _buildMemberItem(_members[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(ProjectMember member) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(member.avatar),
                onBackgroundImageError: (exception, stackTrace) {
                  debugPrint('Error loading avatar: $exception');
                },
                backgroundColor: Color(0xFF5796FF).withValues(alpha: 0.2),
              ),
              if (member.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  member.role,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            onPressed: () {
              _showMemberOptions(member);
            },
          ),
        ],
      ),
    );
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
                leading: Icon(Icons.edit_outlined, color: Color(0xFF333333)),
                title: Text(
                  'Edit Project',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Edit project feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              
              ListTile(
                leading: Icon(Icons.link, color: Color(0xFF333333)),
                title: Text(
                  'Project Link',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Project link copied!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              
              Divider(),
              
              ListTile(
                leading: Icon(Icons.report_outlined, color: Colors.red),
                title: Text(
                  'Report Project',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Report submitted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberOptions(ProjectMember member) {
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
              
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  member.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              ListTile(
                leading: Icon(Icons.person_outline, color: Color(0xFF333333)),
                title: Text(
                  'View Profile',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              
              ListTile(
                leading: Icon(Icons.message_outlined, color: Color(0xFF333333)),
                title: Text(
                  'Send Message',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              
              if (member.role != 'Project Lead')
                ListTile(
                  leading: Icon(Icons.person_remove_outlined, color: Colors.red),
                  title: Text(
                    'Remove from Project',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showRemoveMemberDialog(member);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }



  void _showRemoveMemberDialog(ProjectMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Member',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${member.name} from this project?',
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
              setState(() {
                _members.removeWhere((m) => m.id == member.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${member.name} has been removed'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Remove',
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
}

// Model for project member
class ProjectMember {
  final String id;
  final String name;
  final String avatar;
  final String role;
  final bool isOnline;

  ProjectMember({
    required this.id,
    required this.name,
    required this.avatar,
    required this.role,
    required this.isOnline,
  });
}