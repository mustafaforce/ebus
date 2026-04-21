import 'package:ebus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ebus/features/auth/domain/entities/user_profile.dart';
import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:ebus/features/auth/domain/errors/role_mismatch_exception.dart';
import 'package:ebus/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> loginWithRole({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) async {
    await _remoteDataSource.signIn(email: email, password: password);

    final UserProfile? profile = await _remoteDataSource
        .getCurrentUserProfile();
    if (profile == null) {
      throw StateError('Authenticated user not found');
    }

    if (profile.role != selectedRole) {
      await _remoteDataSource.signOut();
      throw RoleMismatchException(profile.role);
    }
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await _remoteDataSource.signUp(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );

    await _remoteDataSource.signOut();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() {
    return _remoteDataSource.getCurrentUserProfile();
  }

  @override
  Future<void> updateCurrentUserProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
    String? bio,
  }) {
    return _remoteDataSource.updateCurrentUserProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      bio: bio,
    );
  }
}
