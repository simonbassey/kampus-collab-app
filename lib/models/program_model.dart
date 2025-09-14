class ProgramModel {
  final int id;
  final String name;
  final String duration;
  final int facultyId;
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  ProgramModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.facultyId,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'],
      name: json['name'],
      duration: json['duration'],
      facultyId: json['facultyId'],
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'facultyId': facultyId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
