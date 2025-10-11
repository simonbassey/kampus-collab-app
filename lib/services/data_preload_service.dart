import 'package:get/get.dart';
import '../controllers/post_controller.dart';
import '../controllers/student_profile_controller.dart';

/// Service to preload essential data after user login
/// This reduces loading times when navigating to different pages
class DataPreloadService {
  static Future<void> preloadEssentialData() async {
    print('DataPreloadService: Starting data preload...');

    try {
      // Get controllers (will create them if they don't exist)
      final postController = Get.put(PostController());
      final profileController = Get.put(StudentProfileController());

      // Preload in parallel for faster loading
      await Future.wait([
        _preloadPosts(postController),
        _preloadProfile(profileController),
      ]);

      print('DataPreloadService: Data preload completed successfully');
    } catch (e) {
      print('DataPreloadService: Error during preload: $e');
      // Don't throw - we want the app to continue even if preload fails
    }
  }

  static Future<void> _preloadPosts(PostController postController) async {
    try {
      print('DataPreloadService: Preloading posts...');
      await postController.loadPosts();
      print('DataPreloadService: Loaded ${postController.posts.length} posts');
    } catch (e) {
      print('DataPreloadService: Failed to preload posts: $e');
    }
  }

  static Future<void> _preloadProfile(
    StudentProfileController profileController,
  ) async {
    try {
      print('DataPreloadService: Preloading profile...');
      await profileController.fetchCurrentUserProfile();

      if (profileController.studentProfile.value != null) {
        print(
          'DataPreloadService: Loaded profile for ${profileController.studentProfile.value!.fullName}',
        );
      } else {
        print('DataPreloadService: Profile loaded but no data available');
      }
    } catch (e) {
      print('DataPreloadService: Failed to preload profile: $e');
    }
  }

  /// Refresh all preloaded data
  static Future<void> refreshAll() async {
    print('DataPreloadService: Refreshing all data...');
    await preloadEssentialData();
  }
}
