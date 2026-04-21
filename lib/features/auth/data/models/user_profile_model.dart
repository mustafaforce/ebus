import 'package:ebus/features/auth/domain/entities/user_profile.dart';
import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.role,
    super.fullName,
    super.phone,
    super.avatarUrl,
    super.bio,
  });

  factory UserProfileModel.fromDatabase(
    Map<String, dynamic> map, {
    required String fallbackId,
    required String fallbackEmail,
    required UserRole fallbackRole,
  }) {
    final String email = (_asTrimmedOrNull(map['email']) ?? fallbackEmail)
        .trim();
    final String? roleRaw = _asTrimmedOrNull(map['role']);
    final UserRole role = roleRaw == null
        ? fallbackRole
        : UserRole.fromNullable(roleRaw);
    return UserProfileModel(
      id: _asTrimmedOrNull(map['id']) ?? fallbackId,
      email: email.isEmpty ? fallbackEmail : email,
      role: role,
      fullName: _asTrimmedOrNull(map['full_name']),
      phone: _asTrimmedOrNull(map['phone']),
      avatarUrl: _asTrimmedOrNull(map['avatar_url']),
      bio: _asTrimmedOrNull(map['bio']),
    );
  }

  factory UserProfileModel.fromAuthUser(User user) {
    final String fallbackEmail = (user.email ?? 'User').trim();
    return UserProfileModel(
      id: user.id,
      email: fallbackEmail.isEmpty ? 'User' : fallbackEmail,
      role: UserRole.fromNullable(_asTrimmedOrNull(user.userMetadata?['role'])),
      fullName: _asTrimmedOrNull(user.userMetadata?['full_name']),
      phone: _asTrimmedOrNull(user.userMetadata?['phone']),
      avatarUrl: _asTrimmedOrNull(user.userMetadata?['avatar_url']),
      bio: _asTrimmedOrNull(user.userMetadata?['bio']),
    );
  }

  static String? _asTrimmedOrNull(dynamic value) {
    if (value is! String) {
      return null;
    }
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
