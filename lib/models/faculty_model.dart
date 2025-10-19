class FacultyModel {
  final int id;
  final String name;
  final int institutionId;

  FacultyModel({
    required this.id,
    required this.name,
    required this.institutionId,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      id: json['id'] as int,
      name: json['name'] as String,
      institutionId: json['institutionId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'institutionId': institutionId};
  }
}
