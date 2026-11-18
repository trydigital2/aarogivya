/// Domain-level failures keep Firebase/platform details out of the UI layer.
sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure(super.message);
}

final class StorageFailure extends AppFailure {
  const StorageFailure(super.message);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class ConfigurationFailure extends AppFailure {
  const ConfigurationFailure(super.message);
}
