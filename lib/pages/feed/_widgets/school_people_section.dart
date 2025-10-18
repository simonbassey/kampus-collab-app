import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../models/school_person_model.dart';
import '../../../widgets/safe_svg.dart';
import '../../profile/view_profile_page.dart';
import 'school_people_skeleton.dart';

class SchoolPeopleSection extends StatefulWidget {
  const SchoolPeopleSection({Key? key}) : super(key: key);

  @override
  State<SchoolPeopleSection> createState() => _SchoolPeopleSectionState();
}

class _SchoolPeopleSectionState extends State<SchoolPeopleSection> {
  List<SchoolPersonModel> _people = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  // To store the mounted status when initiating async operations
  bool _mounted = true;

  @override
  void dispose() {
    // Mark as unmounted
    _mounted = false;
    super.dispose();
  }

  void _loadPeople() {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    // In a real app, this would be an API call
    Future.delayed(const Duration(milliseconds: 500), () {
      // Check if still mounted before calling setState
      if (_mounted) {
        setState(() {
          _people = SchoolPersonModel.getMockPersons();
          _isLoading = false;
        });
      }
    });
  }

  void _toggleFollow(int index) {
    setState(() {
      _people[index].isFollowing = !_people[index].isFollowing;
    });

    // In a real app, send a request to follow/unfollow API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _people[index].isFollowing
              ? 'You are now following ${_people[index].name}'
              : 'You unfollowed ${_people[index].name}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SchoolPeopleSkeletonLoader();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFFF0F0F0), height: 1, thickness: 1),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // Use SafeSvg which handles errors properly
                SafeSvg.asset(
                  'assets/icons/combo shape.svg',
                  width: 20,
                  height: 20,
                  errorBuilder:
                      (context) =>
                          Icon(Icons.people, size: 20, color: Colors.black87),
                ),
                const SizedBox(width: 8),
                Text(
                  'People in your school',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    letterSpacing: 0,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 380,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: _people.length,
              itemBuilder:
                  (context, index) => _buildPersonCard(_people[index], index),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF0F0F0), height: 1, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildPersonCard(SchoolPersonModel person, int index) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image background with error handling
          Image.network(
            person.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Show a placeholder with person icon when image fails to load
              return Container(
                color: const Color(0xFFEEF5FF),
                child: const Center(
                  child: Icon(Icons.person, size: 80, color: Color(0xFF5796FF)),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFFEEF5FF),
                child: Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                    color: const Color(0xFF5796FF),
                  ),
                ),
              );
            },
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          // Content
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ViewProfilePage(
                              userId: person.id,
                              userName: person.name,
                              userAvatar: person.avatarUrl,
                              isCurrentUser: false,
                            ),
                      ),
                    );
                  },
                  child: Text(
                    person.name,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      fontSize: 18,
                      letterSpacing: 0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  person.university,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _toggleFollow(index),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF5796FF),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      person.isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        letterSpacing: 0,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
