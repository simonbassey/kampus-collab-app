class InstitutionModel {
  final int id;
  final String name;
  final String domain;
  final String collegeType;
  final String verificationStatus;
  final String accountStatus;
  final String createdAt;
  final String? updatedAt;
  final int contactCount;
  final int facultyCount;

  InstitutionModel({
    required this.id,
    required this.name,
    required this.domain,
    required this.collegeType,
    required this.verificationStatus,
    required this.accountStatus,
    required this.createdAt,
    this.updatedAt,
    required this.contactCount,
    required this.facultyCount,
  });

  factory InstitutionModel.fromJson(Map<String, dynamic> json) {
    return InstitutionModel(
      id: json['id'],
      name: json['name'],
      domain: json['domain'],
      collegeType: json['collegeType'],
      verificationStatus: json['verificationStatus'],
      accountStatus: json['accountStatus'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      contactCount: json['contactCount'],
      facultyCount: json['facultyCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
      'collegeType': collegeType,
      'verificationStatus': verificationStatus,
      'accountStatus': accountStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'contactCount': contactCount,
      'facultyCount': facultyCount,
    };
  }
}
