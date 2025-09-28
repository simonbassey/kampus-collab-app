class StudentProfileModel {
  final String? userId;
  final String? fullName;
  final String email;
  final String? profilePhotoUrl;
  final String? shortBio;
  final AcadmicProfileDetails? academicDetails;
  final int followerCount;
  final int followingCount;
  final int postCount;

  StudentProfileModel({
    this.userId,
    this.fullName,
    this.email = '',
    this.profilePhotoUrl,
    this.shortBio,
    this.academicDetails,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    print('StudentProfileModel.fromJson: $json');
    return StudentProfileModel(
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      profilePhotoUrl: json['profilePhotoUrl'],
      shortBio: json['shortBio'],
      academicDetails:
          json['academic'] != null
              ? AcadmicProfileDetails.fromJson(json['academic'])
              : null,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
    );
  }

  // For update requests
  Map<String, dynamic> toUpdateJson() {
    return {
      'fullName': fullName,
      'identityCardBase64': academicDetails?.identityCardBase64,
      'identityNumber': academicDetails?.identityNumber,
      'email': email,
      'profilePicture': profilePhotoUrl,
      'shortBio': shortBio,
      'departmentOrProgramId': academicDetails?.departmentOrProgramId,
      'facultyOrDisciplineId': academicDetails?.facultyOrDisciplineId,
      'yearOfStudy': academicDetails?.yearOfStudy,
    };
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
      institutionId: json['institutionId'],
      institutionName: json['institutionName'],
      facultyOrDisciplineId: json['facultyId'],
      facultyOrDisciplineName: json['facultyName'],
      departmentOrProgramId: json['departmentOrProgramId'],
      departmentOrProgramName: json['departmentOrProgramName'],
      yearOfStudy: json['yearOfStudy'],
    );
  }
}
