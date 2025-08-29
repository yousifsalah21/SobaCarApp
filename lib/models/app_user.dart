class AppUser {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromSupabase(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as int?,
      name: data['name'] as String,
      email: data['email'] as String,
      password: data['password'] as String,
      phone: data['phone'] as String,
      role: data['role'] as String,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
