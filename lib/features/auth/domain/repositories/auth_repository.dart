import 'package:ebus/features/auth/domain/entities/user_profile.dart';
import 'package:ebus/features/auth/domain/entities/user_role.dart';

abstract class AuthRepository {
  Future<void> loginWithRole({
    required String email,
    required String password,
    required UserRole selectedRole,
  });

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<void> signOut();

  Future<UserProfile?> getCurrentUserProfile();
}
