import 'package:aarogivya/features/auth/domain/entities/app_user.dart';
import 'package:aarogivya/features/auth/domain/entities/user_role.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser?> currentUser();

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  Future<AppUser> signInWithGoogle({required UserRole role});

  Future<AppUser> signInWithPhone({
    required String phoneNumber,
    required UserRole role,
    required Future<String> Function(String verificationId) smsCodeProvider,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
