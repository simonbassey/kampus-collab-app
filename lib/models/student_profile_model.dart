class StudentProfileModel {
  final String? userId;
  final int? institutionId;
  final String? identityCardBase64;
  final String? identityNumber;
  final String? email;
  final String? profilePicture;
  final String? shortBio;
  final int? departmentOrProgramId;
  final int? facultyOrDisciplineId;
  final int? yearOfStudy;
  final int? id; // For retrieved profiles

  StudentProfileModel({
    this.userId,
    this.institutionId,
    this.identityCardBase64,
    this.identityNumber,
    this.email,
    this.profilePicture,
    this.shortBio,
    this.departmentOrProgramId,
    this.facultyOrDisciplineId,
    this.yearOfStudy,
    this.id,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      userId: json['userId'],
      institutionId: json['institutionId'],
      identityCardBase64: json['identityCardBase64'],
      identityNumber: json['identityNumber'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      shortBio: json['shortBio'],
      departmentOrProgramId: json['departmentOrProgramId'],
      facultyOrDisciplineId: json['facultyOrDisciplineId'],
      yearOfStudy: json['yearOfStudy'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'institutionId': institutionId,
      'identityCardBase64': identityCardBase64,
      'identityNumber': identityNumber,
      'email': email,
      'profilePicture': profilePicture,
      'shortBio': shortBio,
      'departmentOrProgramId': departmentOrProgramId,
      'facultyOrDisciplineId': facultyOrDisciplineId,
      'yearOfStudy': yearOfStudy,
    };
    // Don't include id for create requests
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  // For update requests
  Map<String, dynamic> toUpdateJson() {
    return {
      'identityCardBase64': identityCardBase64,
      'identityNumber': identityNumber,
      'email': email,
      'profilePicture': profilePicture,
      'shortBio': shortBio,
      'departmentOrProgramId': departmentOrProgramId,
      'facultyOrDisciplineId': facultyOrDisciplineId,
      'yearOfStudy': yearOfStudy,
    };
  }
}
