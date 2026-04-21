import 'package:ebus/features/auth/domain/repositories/auth_repository.dart';

class UpdateCurrentUserProfileUseCase {
  const UpdateCurrentUserProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String fullName,
    String? phone,
    String? avatarUrl,
    String? bio,
  }) {
    return _repository.updateCurrentUserProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      bio: bio,
    );
  }
}
