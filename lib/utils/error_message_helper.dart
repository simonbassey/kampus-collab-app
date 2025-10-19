/// Helper class to clean and format error messages for user display
class ErrorMessageHelper {
  /// Clean error message by removing technical details like URLs, stack traces, etc.
  static String cleanErrorMessage(String errorMessage) {
    String cleaned = errorMessage;

    // Remove URLs (http:// or https://)
    cleaned = cleaned.replaceAll(RegExp(r'https?://[^\s]+'), '[server]');

    // Remove "Exception: " prefix
    cleaned = cleaned.replaceAll(RegExp(r'^Exception:\s*'), '');

    // Remove "Error: " prefix if doubled
    cleaned = cleaned.replaceAll(RegExp(r'^Error:\s*Error:\s*'), 'Error: ');

    // Remove API endpoint paths like /api/...
    cleaned = cleaned.replaceAll(RegExp(r'/api/[^\s]+'), '');

    // Remove any remaining multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Trim
    cleaned = cleaned.trim();

    // If empty after cleaning, return a generic message
    if (cleaned.isEmpty) {
      return 'An error occurred. Please try again.';
    }

    return cleaned;
  }

  /// Get user-friendly error message based on common error patterns
  static String getUserFriendlyMessage(String errorMessage) {
    final cleaned = cleanErrorMessage(errorMessage);

    // Check for common error patterns and provide friendly messages
    if (cleaned.contains('Profile not found for update') ||
        cleaned.contains('Profile not found')) {
      return 'Please set up your academic details first before updating your profile. Go to Settings > Academic Details.';
    }

    if (cleaned.contains('Failed to update profile')) {
      return 'Unable to update profile. Please try again or contact support.';
    }

    if (cleaned.contains('401') || cleaned.contains('Unauthorized')) {
      return 'Session expired. Please log in again.';
    }

    if (cleaned.contains('404') || cleaned.contains('not found')) {
      return 'Resource not found. Please try again later.';
    }

    if (cleaned.contains('500') || cleaned.contains('server error')) {
      return 'Server error. Please try again later.';
    }

    if (cleaned.contains('network') || cleaned.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    if (cleaned.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    // Return cleaned message if no pattern matches
    return cleaned;
  }
}
