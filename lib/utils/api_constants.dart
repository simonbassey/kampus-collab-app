class ApiConstants {
  // Base URL for API requests - using local mock API
  static const String baseUrl = 'http://localhost:3000'; // Use localhost for development
  
  // Uncomment this for production when the real API is available
  // static const String baseUrl = 'https://api.kampuscollab.com';
  
  // API endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String currentUser = '/api/auth/me';
  static const String posts = '/api/posts';
  static const String profiles = '/api/profiles';
  
  // Default timeout durations
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
