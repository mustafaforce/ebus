import 'package:ebus/features/auth/domain/entities/user_role.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
  });

  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
}
