enum UserRole {
  USER,
  RESTAURANT,
  SHIPPER,
}

class UserModel {
  final int id;
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere((e) => e.toString().split('.').last == json['role'], orElse: () => UserRole.USER),
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
