// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import '../../models/post_model.dart';
// import '../../models/student_profile_model.dart';
// import '../feed/post_components/post_list.dart';
// import '../../controllers/post_controller.dart';
// import '../../services/student_profile_service.dart';

// class UserProfile {
//   final String id;
//   final String name;
//   final String avatar;
//   final String handle;
//   final String role;
//   final String bio;
//   final int followers;
//   final int following;
//   final int posts;
//   final bool isFollowing;
//   final StudentProfileModel? fullProfile;

//   const UserProfile({
//     required this.id,
//     required this.name,
//     required this.avatar,
//     required this.handle,
//     required this.role,
//     required this.bio,
//     required this.followers,
//     required this.following,
//     required this.posts,
//     this.isFollowing = false,
//     this.fullProfile,
//   });

//   // Create a profile from StudentProfileModel
//   factory UserProfile.fromStudentProfile(StudentProfileModel profile) {
//     return UserProfile(
//       id: profile.userId ?? '',
//       name: profile.fullName ?? 'Anonymous',
//       avatar: profile.profilePhotoUrl ?? '',
//       handle:
//           '@${(profile.fullName ?? 'user').toLowerCase().replaceAll(' ', '')}',
//       role: profile.academicDetails?.departmentOrProgramName ?? 'Student',
//       bio: profile.shortBio ?? 'No bio available',
//       followers: profile.followerCount,
//       following: profile.followingCount,
//       posts: profile.postCount,
//       fullProfile: profile,
//     );
//   }

//   // Create a mock profile for testing
//   factory UserProfile.fromPostModel(PostModel post) {
//     return UserProfile(
//       id: post.userId,
//       name: post.userName,
//       avatar: post.userAvatar,
//       handle: post.userHandle,
//       role: post.userRole,
//       bio:
//           'This is a mock bio for the user profile. In a real app, this would be fetched from the user data.',
//       followers: 120,
//       following: 45,
//       posts: 23,
//     );
//   }
// }

// class UserProfileScreen extends StatefulWidget {
//   final UserProfile user;

//   const UserProfileScreen({Key? key, required this.user}) : super(key: key);

//   static void showProfile(BuildContext context, PostModel post) {
//     final userProfile = UserProfile.fromPostModel(post);
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => UserProfileScreen(user: userProfile),
//       ),
//     );
//   }

//   @override
//   State<UserProfileScreen> createState() => _UserProfileScreenState();
// }

// class _UserProfileScreenState extends State<UserProfileScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final PostController _postController = Get.put(PostController());
//   final StudentProfileService _profileService = StudentProfileService();
//   bool _isLoadingProfile = false;
//   bool _isFollowing = false;
//   UserProfile? _fullUserProfile;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _isFollowing = widget.user.isFollowing;
//     _loadUserProfile();
//     _loadUserPosts();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() {
//       _isLoadingProfile = true;
//     });

//     try {
//       debugPrint(
//         'UserProfileScreen: Loading profile for user ${widget.user.id}',
//       );
//       final profile = await _profileService.getUserProfileById(widget.user.id);

//       setState(() {
//         _fullUserProfile = UserProfile.fromStudentProfile(profile);
//         _isLoadingProfile = false;
//       });
//       debugPrint('UserProfileScreen: Profile loaded successfully');
//     } catch (e) {
//       setState(() {
//         _isLoadingProfile = false;
//       });
//       debugPrint('UserProfileScreen: Error loading profile - $e');
//     }
//   }

//   void _loadUserPosts() {
//     // Load real posts from API
//     _postController
//         .loadUserPosts(widget.user.id)
//         .then((_) {
//           debugPrint('UserProfileScreen: Posts loaded successfully');
//         })
//         .catchError((error) {
//           debugPrint('UserProfileScreen: Error loading posts - $error');
//         });
//   }

//   void _toggleFollow() {
//     setState(() {
//       _isFollowing = !_isFollowing;
//     });

//     // Show a snackbar confirmation
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           _isFollowing
//               ? 'You are now following ${widget.user.name}'
//               : 'You unfollowed ${widget.user.name}',
//         ),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   // Helper function to check if string is URL
//   bool _isUrl(String? str) {
//     if (str == null || str.isEmpty) return false;
//     return str.startsWith('http://') || str.startsWith('https://');
//   }

//   // Helper function to convert base64 to image
//   Uint8List? _convertBase64ToImage(String? base64String) {
//     if (base64String == null || base64String.isEmpty) return null;
//     try {
//       // Handle data URI format (e.g., "data:image/png;base64,...")
//       if (base64String.startsWith('data:')) {
//         base64String = base64String.split(',').last;
//       }
//       return base64Decode(base64String);
//     } catch (e) {
//       debugPrint('Error decoding profile image: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final displayProfile = _fullUserProfile ?? widget.user;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverAppBar(
//               expandedHeight: 200.0,
//               floating: false,
//               pinned: true,
//               backgroundColor: Color(0xFF5796FF),
//               flexibleSpace: FlexibleSpaceBar(
//                 background: Container(
//                   color: Color(0xFF5796FF),
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             if (displayProfile.avatar.isNotEmpty) {
//                               // Show enlarged photo
//                             }
//                           },
//                           child: CircleAvatar(
//                             radius: 50.0,
//                             backgroundImage:
//                                 _isUrl(displayProfile.avatar)
//                                     ? NetworkImage(displayProfile.avatar)
//                                     : null,
//                             child:
//                                 !_isUrl(displayProfile.avatar)
//                                     ? (_convertBase64ToImage(
//                                               displayProfile.avatar,
//                                             ) !=
//                                             null
//                                         ? ClipOval(
//                                           child: Image.memory(
//                                             _convertBase64ToImage(
//                                               displayProfile.avatar,
//                                             )!,
//                                             width: 100,
//                                             height: 100,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         )
//                                         : Icon(
//                                           Icons.person,
//                                           size: 50,
//                                           color: Colors.white,
//                                         ))
//                                     : null,
//                             onBackgroundImageError: (exception, stackTrace) {
//                               debugPrint('Error loading avatar: $exception');
//                             },
//                             backgroundColor: Color(0xFF5796FF).withOpacity(0.3),
//                           ),
//                         ),
//                         const SizedBox(height: 10.0),
//                         Text(
//                           displayProfile.name,
//                           style: const TextStyle(
//                             fontSize: 22.0,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                         Text(
//                           displayProfile.handle,
//                           style: const TextStyle(
//                             fontSize: 16.0,
//                             color: Colors.white70,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SliverPersistentHeader(
//               delegate: _ProfileInfoDelegate(
//                 user: displayProfile,
//                 fullProfile: _fullUserProfile,
//                 isFollowing: _isFollowing,
//                 isLoadingProfile: _isLoadingProfile,
//                 onFollowTap: _toggleFollow,
//               ),
//               pinned: true,
//             ),
//             SliverPersistentHeader(
//               delegate: _TabBarDelegate(tabController: _tabController),
//               pinned: true,
//             ),
//           ];
//         },
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             // Posts Tab
//             Obx(() {
//               if (_postController.isLoading.value &&
//                   _postController.userPosts.isEmpty) {
//                 return const Center(
//                   child: CircularProgressIndicator(color: Color(0xFF5796FF)),
//                 );
//               }

//               if (_postController.userPosts.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.post_add, size: 100, color: Colors.grey[300]),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No posts yet',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey[500],
//                           fontFamily: 'Poppins',
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return PostList(posts: _postController.userPosts);
//             }),

//             // Photos Tab
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.photo_library, size: 100, color: Colors.grey[300]),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Photos',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey[500],
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Saved Tab
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.bookmark, size: 100, color: Colors.grey[300]),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Saved Items',
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey[500],
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ProfileInfoDelegate extends SliverPersistentHeaderDelegate {
//   final UserProfile user;
//   final UserProfile? fullProfile;
//   final bool isFollowing;
//   final bool isLoadingProfile;
//   final VoidCallback onFollowTap;

//   _ProfileInfoDelegate({
//     required this.user,
//     this.fullProfile,
//     required this.isFollowing,
//     this.isLoadingProfile = false,
//     required this.onFollowTap,
//   });

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     final displayProfile = fullProfile ?? user;
//     final profile = displayProfile.fullProfile;

//     return Container(
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Role and Follow Button
//             Row(
//               children: [
//                 if (profile?.academicDetails != null)
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Color(0xFF5796FF).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Text(
//                             profile!.academicDetails!.departmentOrProgramName,
//                             style: TextStyle(
//                               color: Color(0xFF5796FF),
//                               fontWeight: FontWeight.w500,
//                               fontSize: 12,
//                               fontFamily: 'Poppins',
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4),
//                           child: Text(
//                             profile.academicDetails!.institutionName,
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: Colors.grey[600],
//                               fontFamily: 'Poppins',
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 else
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Color(0xFF5796FF).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Text(
//                       displayProfile.role,
//                       style: TextStyle(
//                         color: Color(0xFF5796FF),
//                         fontWeight: FontWeight.w500,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                   ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: onFollowTap,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         isFollowing ? Colors.grey[200] : Color(0xFF5796FF),
//                     foregroundColor:
//                         isFollowing ? Colors.black87 : Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: Text(
//                     isFollowing ? 'Following' : 'Follow',
//                     style: TextStyle(fontFamily: 'Poppins'),
//                   ),
//                 ),
//               ],
//             ),

//             // Bio
//             if (displayProfile.bio.isNotEmpty &&
//                 displayProfile.bio != 'No bio available') ...[
//               const SizedBox(height: 16),
//               Text(
//                 displayProfile.bio,
//                 style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
//               ),
//             ],

//             // Additional profile info
//             if (profile != null && profile.email.isNotEmpty) ...[
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       profile.email,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[700],
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],

//             // Stats
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatColumn(displayProfile.posts.toString(), 'Posts'),
//                 _buildStatColumn(
//                   displayProfile.followers.toString(),
//                   'Followers',
//                 ),
//                 _buildStatColumn(
//                   displayProfile.following.toString(),
//                   'Following',
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatColumn(String count, String label) {
//     return Column(
//       children: [
//         Text(
//           count,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
//       ],
//     );
//   }

//   @override
//   double get maxExtent => 250.0;

//   @override
//   double get minExtent => 250.0;

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
//     return true;
//   }
// }

// class _TabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabController tabController;

//   _TabBarDelegate({required this.tabController});

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(
//       color: Colors.white,
//       child: TabBar(
//         controller: tabController,
//         labelColor: Theme.of(context).primaryColor,
//         unselectedLabelColor: Colors.grey,
//         indicatorColor: Theme.of(context).primaryColor,
//         tabs: const [
//           Tab(icon: Icon(Icons.grid_on), text: 'Posts'),
//           Tab(icon: Icon(Icons.photo_library), text: 'Photos'),
//           Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
//         ],
//       ),
//     );
//   }

//   @override
//   double get maxExtent => 50.0;

//   @override
//   double get minExtent => 50.0;

//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
//     return true;
//   }
// }
