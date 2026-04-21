enum UserRole {
  driver,
  passenger;

  String get value => name;

  String get label {
    switch (this) {
      case UserRole.driver:
        return 'Driver';
      case UserRole.passenger:
        return 'Passenger';
    }
  }

  static UserRole fromNullable(String? role) {
    switch ((role ?? '').trim().toLowerCase()) {
      case 'driver':
        return UserRole.driver;
      case 'passenger':
        return UserRole.passenger;
      default:
        return UserRole.passenger;
    }
  }
}
