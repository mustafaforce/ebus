import 'package:ebus/features/auth/domain/entities/user_role.dart';

class RoleMismatchException implements Exception {
  const RoleMismatchException(this.actualRole);

  final UserRole actualRole;

  @override
  String toString() => 'RoleMismatchException(actualRole: ${actualRole.value})';
}
