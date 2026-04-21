import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:ebus/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) {
    return _repository.signUp(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }
}
