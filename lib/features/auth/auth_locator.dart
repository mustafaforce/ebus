import 'package:ebus/core/network/supabase_client_provider.dart';
import 'package:ebus/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ebus/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ebus/features/auth/domain/repositories/auth_repository.dart';
import 'package:ebus/features/auth/domain/usecases/get_current_user_profile_use_case.dart';
import 'package:ebus/features/auth/domain/usecases/login_with_role_use_case.dart';
import 'package:ebus/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:ebus/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:ebus/features/auth/domain/usecases/update_current_user_profile_use_case.dart';

class AuthLocator {
  AuthLocator._();

  static final AuthRemoteDataSource _remoteDataSource =
      SupabaseAuthRemoteDataSource(SupabaseClientProvider.client);

  static final AuthRepository _repository = AuthRepositoryImpl(
    _remoteDataSource,
  );

  static final LoginWithRoleUseCase loginWithRoleUseCase = LoginWithRoleUseCase(
    _repository,
  );
  static final SignUpUseCase signUpUseCase = SignUpUseCase(_repository);
  static final SignOutUseCase signOutUseCase = SignOutUseCase(_repository);
  static final GetCurrentUserProfileUseCase getCurrentUserProfileUseCase =
      GetCurrentUserProfileUseCase(_repository);
  static final UpdateCurrentUserProfileUseCase updateCurrentUserProfileUseCase =
      UpdateCurrentUserProfileUseCase(_repository);
}
