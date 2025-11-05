// ========================
// USER MODEL
// ========================

class User {
  final String id;
  final String username;
  final String email;
  final String image;
  final String? role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.image,
    this.role,
  });

  // Chuyển từ JSON sang User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  // Chuyển từ User object sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'image': image,
      'role': role,
    };
  }

  // Copy với các giá trị mới
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? image,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      image: image ?? this.image,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, image: $image, role: $role)';
  }
}