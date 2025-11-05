class User {
  final String id;
  final String username;
  final String email;
  final String image;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.image,
  });

  // JSON->User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
    );
  }

  // User object->JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'image': image,
    };
  }


  User copyWith({
    String? id,
    String? username,
    String? email,
    String? image,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, image: $image)';
  }
}
