import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui';
import '../../../models/school_person_model.dart';
import '../../profile/view_profile_page.dart';

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

  void _loadPeople() {
    setState(() {
      _isLoading = true;
    });

    // In a real app, this would be an API call
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _people = SchoolPersonModel.getMockPersons();
        _isLoading = false;
      });
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
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // Try to use SVG icon with fallback to regular icon
                Builder(
                  builder: (context) {
                    try {
                      return SvgPicture.asset(
                        'assets/icons/combo shape.svg',
                        width: 20,
                        height: 20,
                      );
                    } catch (e) {
                      return Icon(
                        Icons.people,
                        size: 20,
                        color: Colors.black87,
                      );
                    }
                  },
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
          // Image background
          Image.network(person.avatarUrl, fit: BoxFit.cover),
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
