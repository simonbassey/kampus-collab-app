import 'package:get/get.dart';
import 'package:inkstryq/pages/feed/feed_screen.dart';
import 'package:inkstryq/pages/onboarding/academic_details_screen.dart';
import 'package:inkstryq/pages/auth/create_account_flow/create_account_screen.dart';
import 'package:inkstryq/pages/auth/create_account_flow/create_account_otp_screen.dart';
import 'package:inkstryq/pages/auth/forgot_password_flow/create_new_password_screen.dart';
import 'package:inkstryq/pages/auth/forgot_password_flow/forgot_password_otp_screen.dart';
import 'package:inkstryq/pages/auth/forgot_password_flow/forgot_password_screen.dart';
import 'package:inkstryq/pages/auth/forgot_password_flow/password_reset_success_screen.dart';
import 'package:inkstryq/pages/profile/profile_setup_screen.dart';
import 'package:inkstryq/pages/profile/profile_page.dart';
import '../pages/splash_screen.dart';
import '../pages/first_screen.dart';
import '../pages/auth/login_screen.dart';
import '../pages/auth/signup_screen.dart';

class AppPages {
  static const initial = '/splash';

  static final routes = [
    GetPage(
      name: '/splash',
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: '/first',
      page: () => const FirstScreen(),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: '/signup',
      page: () => const SignupScreen(),
    ),
    GetPage(
      name: '/forgot-password',
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: '/forgot-password-otp',
      page: () => const ForgotPasswordOtpScreen(),
    ),
    GetPage(
      name: '/create-new-password',
      page: () => const CreateNewPasswordScreen(),
    ),
    GetPage(
      name: '/password-reset-success',
      page: () => const PasswordResetSuccessScreen(),
    ),
    GetPage(
      name: '/create-account',
      page: () => const CreateAccountScreen(),
    ),
    GetPage(
      name: '/create-account-otp',
      page: () => const CreateAccountOtpScreen(),
    ),
    GetPage(
      name: '/academic-details',
      page: () => const AcademicDetailsScreen(),
    ),
    GetPage(
      name: '/feed',
      page: () => const FeedScreen(),
    ),
    GetPage(
      name: '/profile-setup',
      page: () => const ProfileSetupScreen(),
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfilePage(),
    ),
  ];
}
