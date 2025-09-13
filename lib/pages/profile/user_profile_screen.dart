import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../feed/post_components/post_list.dart';

class UserProfile {
  final String id;
  final String name;
  final String avatar;
  final String handle;
  final String role;
  final String bio;
  final int followers;
  final int following;
  final int posts;
  final bool isFollowing;
  
  const UserProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.handle,
    required this.role,
    required this.bio,
    required this.followers,
    required this.following,
    required this.posts,
    this.isFollowing = false,
  });
  
  // Create a mock profile for testing
  factory UserProfile.fromPostModel(PostModel post) {
    return UserProfile(
      id: post.userId,
      name: post.userName,
      avatar: post.userAvatar,
      handle: post.userHandle,
      role: post.userRole,
      bio: 'This is a mock bio for the user profile. In a real app, this would be fetched from the user data.',
      followers: 120,
      following: 45,
      posts: 23,
    );
  }
}

class UserProfileScreen extends StatefulWidget {
  final UserProfile user;
  
  const UserProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);
  
  static void showProfile(BuildContext context, PostModel post) {
    final userProfile = UserProfile.fromPostModel(post);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(user: userProfile),
      ),
    );
  }
  
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<PostModel> _userPosts = [];
  bool _isLoading = false;
  bool _isFollowing = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isFollowing = widget.user.isFollowing;
    _loadUserPosts();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _loadUserPosts() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading posts from API
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _userPosts.addAll([
          PostModel.mockText(),
          PostModel.mockImage(),
          PostModel.mockLink(),
        ]);
        _isLoading = false;
      });
    });
  }
  
  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    
    // Show a snackbar confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFollowing 
          ? 'You are now following ${widget.user.name}' 
          : 'You unfollowed ${widget.user.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50.0,
                          backgroundImage: NetworkImage(widget.user.avatar),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.user.handle,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _ProfileInfoDelegate(
                user: widget.user,
                isFollowing: _isFollowing,
                onFollowTap: _toggleFollow,
              ),
              pinned: true,
            ),
            SliverPersistentHeader(
              delegate: _TabBarDelegate(
                tabController: _tabController,
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Posts Tab
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PostList(posts: _userPosts),
            
            // Photos Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Photos',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            
            // Saved Tab
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Saved Items',
                    style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoDelegate extends SliverPersistentHeaderDelegate {
  final UserProfile user;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  
  _ProfileInfoDelegate({
    required this.user,
    required this.isFollowing,
    required this.onFollowTap,
  });
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role and Follow Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onFollowTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing
                        ? Colors.grey[200]
                        : Theme.of(context).primaryColor,
                    foregroundColor: isFollowing
                        ? Colors.black87
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(isFollowing ? 'Following' : 'Follow'),
                ),
              ],
            ),
            
            // Bio
            if (user.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(user.bio),
            ],
            
            // Stats
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(user.posts.toString(), 'Posts'),
                _buildStatColumn(user.followers.toString(), 'Followers'),
                _buildStatColumn(user.following.toString(), 'Following'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  @override
  double get maxExtent => 180.0;
  
  @override
  double get minExtent => 180.0;
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  
  _TabBarDelegate({required this.tabController});
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
          Tab(icon: Icon(Icons.photo_library), text: 'Photos'),
          Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
        ],
      ),
    );
  }
  
  @override
  double get maxExtent => 50.0;
  
  @override
  double get minExtent => 50.0;
  
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
