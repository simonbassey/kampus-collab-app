import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Register services first
    Get.lazyPut<AuthService>(() => AuthService());
    
    // Then register controllers that depend on services
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
