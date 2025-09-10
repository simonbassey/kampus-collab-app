import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class FeedSearchScreen extends StatefulWidget {
  const FeedSearchScreen({Key? key}) : super(key: key);

  @override
  State<FeedSearchScreen> createState() => _FeedSearchScreenState();
}

class _FeedSearchScreenState extends State<FeedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  List<String> _searchResults = [];

  // Mock categories for demonstration
  final List<String> _categories = [
    'Campus News',
    'Events',
    'Study Groups',
    'Course Materials',
    'Professors',
    'Sports',
    'Clubs',
    'Roommates',
  ];

  @override
  void initState() {
    super.initState();
    // Focus on search field when screen opens
    Future.delayed(const Duration(milliseconds: 300), () {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    // This would be replaced with actual search functionality
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    // Mock search results based on the query
    setState(() {
      _isSearching = true;
      _searchResults = List.generate(
        5,
        (index) => 'Result for "$query" #${index + 1}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: InputDecoration(
            hintText: 'Search posts, people, topics...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            border: InputBorder.none,
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                    : null,
          ),
          onChanged: _performSearch,
        ),
      ),
      body: _isSearching ? _buildSearchResults() : _buildSuggestedContent(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/search 02.svg',
              height: 48,
              width: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "${_searchController.text}"',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_searchResults[index]),
          leading: CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.article, color: Colors.grey),
          ),
          onTap: () {
            // Navigate to the post or profile
          },
        );
      },
    );
  }

  Widget _buildSuggestedContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildCategoriesGrid(),

          const SizedBox(height: 32),
          const Text(
            'Trending Topics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTrendingTopics(),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            _searchController.text = _categories[index];
            _performSearch(_categories[index]);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.primaries[index % Colors.primaries.length]
                  .withOpacity(0.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Center(
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.primaries[index % Colors.primaries.length],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendingTopics() {
    final trendingTopics = [
      'Campus Renovations',
      'Final Exam Schedule',
      'New Course Registration',
      'Student Government Elections',
      'Internship Opportunities',
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trendingTopics.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.trending_up, color: Colors.blue[400]),
          title: Text(trendingTopics[index]),
          trailing: Text(
            '${(index + 1) * 12} posts',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          onTap: () {
            _searchController.text = trendingTopics[index];
            _performSearch(trendingTopics[index]);
          },
        );
      },
    );
  }
}
