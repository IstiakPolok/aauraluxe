class UserProfile {
  final String id;
  final String email;
  final String role; // 'super_admin', 'admin', 'staff', 'customer'
  final bool isBlocked;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.isBlocked = false,
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
      isBlocked: json['is_blocked'] as bool? ?? false,
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
      'is_blocked': isBlocked,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
