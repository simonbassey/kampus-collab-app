class ApiConstants {
  // Base API URL
  static const String baseUrl = 'https://kampus-colab-cdgdg9gec3g7b0bb.canadacentral-01.azurewebsites.net';
  static const String apiPrefix = '$baseUrl/api';
  
  // Auth endpoints
  static const String token = '$apiPrefix/auth/Token';
  
  // Onboarding endpoints
  static const String initiateOnboarding = '$apiPrefix/onboarding/initiate';
  static const String completeOnboarding = '$apiPrefix/onboarding/{email}/complete';
  
  // OTP endpoints
  static const String verifyOtp = '$apiPrefix/otp/verify';
  static const String resendOtp = '$apiPrefix/otp/resend/{recipientEmail}';
  
  // User endpoints
  static const String getUserById = '$apiPrefix/users/{id}';
  static const String getAllUsers = '$apiPrefix/users';
  static const String getUserFollowers = '$apiPrefix/users/{userId}/followers';
  static const String getUserFollowing = '$apiPrefix/users/{userId}/following';
  static const String followUser = '$apiPrefix/users/{userId}/follow';
  static const String unfollowUser = '$apiPrefix/users/{userId}/unfollow';
  
  // Post endpoints
  static const String getPosts = '$apiPrefix/posts';
  static const String createPost = '$apiPrefix/posts';
  static const String getPostById = '$apiPrefix/posts/{id}';
  
  // Student Profile endpoints
  static const String createStudentProfile = '$apiPrefix/StudentProfiles/create';
  static const String getStudentProfileById = '$apiPrefix/StudentProfiles/{id}';
  static const String getAllStudentProfiles = '$apiPrefix/StudentProfiles/all';
  static const String updateStudentProfile = '$apiPrefix/StudentProfiles/update/{id}';
  static const String deleteStudentProfile = '$apiPrefix/StudentProfiles/delete/{id}';
  
  // Institution endpoints
  static const String createInstitution = '$apiPrefix/institutions/create';
  static const String getInstitutionById = '$apiPrefix/institutions/{id}';
  static const String updateInstitution = '$apiPrefix/institutions/{id}';
  static const String deleteInstitution = '$apiPrefix/institutions/{id}';
  static const String getAllInstitutions = '$apiPrefix/institutions';
  
  // Faculty endpoints
  static const String addFaculty = '$apiPrefix/institutions/{institutionId}/faculties/add';
  static const String getFaculties = '$apiPrefix/institutions/{institutionId}/faculties';
  static const String getFacultyById = '$apiPrefix/institutions/{institutionId}/faculties/{facultyId}';
  static const String updateFaculty = '$apiPrefix/institutions/{institutionId}/faculties/{facultyId}';
  static const String deleteFaculty = '$apiPrefix/institutions/{institutionId}/faculties/{facultyId}';
  
  // Program endpoints
  static const String createProgram = '$apiPrefix/institutions/{institutionId}/faculties/{facultyId}/programs';
  static const String getPrograms = '$apiPrefix/institutions/{institutionId}/faculties/{facultyId}/programs';
  static const String getProgramById = '$apiPrefix/institutions/{institutionId}/faculties/{facultyId}/programs/{programId}';
  static const String updateProgram = '$apiPrefix/institutions/{institutionId}/faculties/{facultyId}/programs/{programId}';
  static const String deleteProgram = '$apiPrefix/institutions/{institutionId}/faculties/{facultyId}/programs/{programId}';
  
  // Institution Contact endpoints
  static const String createInstitutionContact = '$apiPrefix/InstitutionContact';
  static const String getInstitutionContactById = '$apiPrefix/InstitutionContact/{id}';
  static const String updateInstitutionContact = '$apiPrefix/InstitutionContact/{id}';
  static const String deleteInstitutionContact = '$apiPrefix/InstitutionContact/{id}';
  static const String getInstitutionContactsByInstitutionId = '$apiPrefix/InstitutionContact/institution/{institutionId}';
}


