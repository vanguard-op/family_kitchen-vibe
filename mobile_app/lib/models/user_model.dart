class UserModel {
  final String userId;
  final String email;
  final String name;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      email: json['email'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
