import 'package:aarogivya/core/error/app_failure.dart';

AppFailure mapFirebaseError(Object error) {
  if (error is AppFailure) return error;

  return DatabaseFailure(
    error.toString().replaceFirst(
          RegExp(r'^[_A-Za-z]+\s*(exception|error):\s*', caseSensitive: false),
          '',
        ),
  );
}
