import 'package:aarogivya/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('rejects invalid email addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('patient@example.com'), isNull);
    });

    test('requires a minimum password length', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('long-enough'), isNull);
    });

    test('validates international phone numbers', () {
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('+919876543210'), isNull);
    });

    test('checks password confirmation', () {
      expect(Validators.confirmPassword('different', 'password'), isNotNull);
      expect(Validators.confirmPassword('password', 'password'), isNull);
    });
  });
}
