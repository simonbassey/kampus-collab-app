class SchoolPersonModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String university;
  bool isFollowing;

  SchoolPersonModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.university,
    this.isFollowing = false,
  });

  // Mock data for testing
  static List<SchoolPersonModel> getMockPersons() {
    return [
      SchoolPersonModel(
        id: '1',
        name: 'Aeden Joseph',
        avatarUrl: 'https://images.unsplash.com/photo-1531384441138-2736e62e0919?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
        university: 'University Of Lagos',
      ),
      SchoolPersonModel(
        id: '2',
        name: 'Victory Ekpenyor',
        avatarUrl: 'https://images.unsplash.com/photo-1598550477091-0795cc0bbee8?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
        university: 'University Of Uyo',
      ),
      SchoolPersonModel(
        id: '3',
        name: 'Michael Oluwatobi',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
        university: 'University Of Ibadan',
      ),
      SchoolPersonModel(
        id: '4',
        name: 'Sarah Adeleke',
        avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
        university: 'University Of Benin',
      ),
      SchoolPersonModel(
        id: '5',
        name: 'Daniel Eze',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80',
        university: 'University Of Port Harcourt',
      ),
    ];
  }
}
