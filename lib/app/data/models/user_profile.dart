class UserProfile {
  final String id;
  final String email;
  final String role; // 'super_admin', 'admin', 'staff', 'customer'
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin' || role == 'super_admin';
  bool get isStaff => role == 'staff' || role == 'admin' || role == 'super_admin';
  bool get isCustomer => role == 'customer';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'customer',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
