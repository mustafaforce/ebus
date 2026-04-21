import 'package:ebus/features/auth/data/models/user_profile_model.dart';
import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<void> signIn({required String email, required String password});

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<void> signOut();

  Future<UserProfileModel?> getCurrentUserProfile();
}

class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  SupabaseAuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  @override
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await _client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
      data: <String, dynamic>{'full_name': fullName.trim(), 'role': role.value},
    );
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  @override
  Future<UserProfileModel?> getCurrentUserProfile() async {
    final User? user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final Map<String, dynamic>? map = await _client
        .from('users')
        .select('id, email, full_name, role')
        .eq('id', user.id)
        .maybeSingle();

    if (map == null) {
      return UserProfileModel.fromAuthUser(user);
    }

    return UserProfileModel.fromDatabase(
      map,
      fallbackId: user.id,
      fallbackEmail: user.email ?? 'User',
      fallbackRole: UserRole.fromNullable(
        _asTrimmedOrNull(user.userMetadata?['role']),
      ),
    );
  }

  String? _asTrimmedOrNull(dynamic value) {
    if (value is! String) {
      return null;
    }
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
