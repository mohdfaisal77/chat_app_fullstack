class UserModel {
  final String id;
  final String email;
  UserModel({required this.id, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
        email: j['email'] ?? '',
      );
}
