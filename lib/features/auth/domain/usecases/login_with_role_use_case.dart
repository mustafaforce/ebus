import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:ebus/features/auth/domain/repositories/auth_repository.dart';

class LoginWithRoleUseCase {
  const LoginWithRoleUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String password,
    required UserRole selectedRole,
  }) {
    return _repository.loginWithRole(
      email: email,
      password: password,
      selectedRole: selectedRole,
    );
  }
}
