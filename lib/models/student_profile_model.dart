class StudentProfileModel {
  final int? id;
  final String? userId;
  final String? fullName;
  final String email;
  final String? profilePhotoUrl;
  final String? shortBio;
  final AcadmicProfileDetails? academicDetails;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final int? institutionId;
  final String? identityCardBase64;
  final String? identityNumber;
  final int? departmentOrProgramId;
  final int? facultyId;
  final int? yearOfStudy;
  final int? completionPercentage;
  final DateTime? createdAt;
  final DateTime? lastUpdatedAt;

  StudentProfileModel({
    this.id,
    this.userId,
    this.fullName,
    this.email = '',
    this.profilePhotoUrl,
    this.shortBio,
    this.academicDetails,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.institutionId,
    this.identityCardBase64,
    this.identityNumber,
    this.departmentOrProgramId,
    this.facultyId,
    this.yearOfStudy,
    this.completionPercentage,
    this.createdAt,
    this.lastUpdatedAt,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    print('StudentProfileModel.fromJson: $json');
    return StudentProfileModel(
      id: json['id'],
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'] ?? '',
      profilePhotoUrl: json['profilePhotoUrl'],
      shortBio: json['shortBio'],
      academicDetails:
          json['academic'] != null
              ? AcadmicProfileDetails.fromJson(json['academic'])
              : null,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      institutionId: json['institutionId'],
      identityCardBase64: json['identityCardBase64'],
      identityNumber: json['identityNumber'],
      departmentOrProgramId: json['departmentOrProgramId'],
      facultyId: json['facultyId'],
      yearOfStudy: json['yearOfStudy'],
      completionPercentage: json['completionPercentage'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastUpdatedAt:
          json['lastUpdatedAt'] != null
              ? DateTime.parse(json['lastUpdatedAt'])
              : null,
    );
  }

  // For update requests using the legacy API
  Map<String, dynamic> toUpdateJson() {
    return {
      'fullName': fullName,
      'identityCardBase64':
          academicDetails?.identityCardBase64 ?? identityCardBase64,
      'identityNumber': academicDetails?.identityNumber ?? identityNumber,
      'email': email,
      'profilePicture': profilePhotoUrl,
      'shortBio': shortBio,
      'departmentOrProgramId':
          academicDetails?.departmentOrProgramId ?? departmentOrProgramId,
      'facultyOrDisciplineId':
          academicDetails?.facultyOrDisciplineId ?? facultyId,
      'yearOfStudy': academicDetails?.yearOfStudy ?? yearOfStudy,
    };
  }

  // For update requests using the new profile/me API
  Map<String, dynamic> toProfileUpdateJson() {
    final Map<String, dynamic> data = {};

    // Only include non-null fields in the update
    if (identityCardBase64 != null)
      data['identityCardBase64'] = identityCardBase64;
    if (identityNumber != null) data['identityNumber'] = identityNumber;
    if (profilePhotoUrl != null) data['profilePhotoUrl'] = profilePhotoUrl;
    if (shortBio != null) data['shortBio'] = shortBio;
    if (departmentOrProgramId != null)
      data['departmentOrProgramId'] = departmentOrProgramId;
    if (facultyId != null) data['facultyId'] = facultyId;
    if (yearOfStudy != null) data['yearOfStudy'] = yearOfStudy;

    return data;
  }
}

class AcadmicProfileDetails {
  final int institutionId;
  final String institutionName;
  final int facultyOrDisciplineId;
  final String facultyOrDisciplineName;
  final int departmentOrProgramId;
  final String departmentOrProgramName;
  final int yearOfStudy;
  final String? identityCardBase64;
  final String? identityNumber;

  AcadmicProfileDetails({
    required this.institutionId,
    required this.institutionName,
    required this.facultyOrDisciplineId,
    required this.facultyOrDisciplineName,
    required this.departmentOrProgramId,
    required this.departmentOrProgramName,
    required this.yearOfStudy,
    this.identityCardBase64,
    this.identityNumber,
  });

  factory AcadmicProfileDetails.fromJson(Map<String, dynamic> json) {
    return AcadmicProfileDetails(
      institutionId: json['institutionId'] as int,
      institutionName: json['institutionName'] as String,
      // API returns 'facultyId' and 'facultyName', map them to our field names
      facultyOrDisciplineId:
          (json['facultyOrDisciplineId'] ?? json['facultyId']) as int,
      facultyOrDisciplineName:
          (json['facultyOrDisciplineName'] ?? json['facultyName']) as String,
      departmentOrProgramId: json['departmentOrProgramId'] as int,
      departmentOrProgramName: json['departmentOrProgramName'] as String,
      yearOfStudy: json['yearOfStudy'] as int,
      identityCardBase64: json['identityCardBase64'] as String?,
      identityNumber: json['identityNumber'] as String?,
    );
  }
}
