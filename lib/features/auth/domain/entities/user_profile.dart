import 'package:ebus/features/auth/domain/entities/user_role.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
}
