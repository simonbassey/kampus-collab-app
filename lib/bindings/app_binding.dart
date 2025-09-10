import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/student_profile_controller.dart';
import '../services/auth_service.dart';
import '../services/student_profile_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Register services first
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<StudentProfileService>(() => StudentProfileService());
    
    // Register AuthController first and make it immediately available
    Get.put<AuthController>(AuthController());
    
    // Then register StudentProfileController that depends on AuthController
    // Using Get.put instead of Get.lazyPut to ensure it's immediately available
    Get.put<StudentProfileController>(StudentProfileController());
  }
}
