import 'dart:async';
import 'package:aarogivya/core/error/app_failure.dart';
import 'package:aarogivya/features/auth/domain/entities/app_user.dart';
import 'package:aarogivya/features/auth/domain/entities/user_role.dart';
import 'package:aarogivya/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._preferences) {
    _loadUser();
  }

  final SharedPreferences _preferences;
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  static const _keyUid = 'auth_user_uid';
  static const _keyEmail = 'auth_user_email';
  static const _keyName = 'auth_user_name';
  static const _keyRole = 'auth_user_role';

  void _loadUser() {
    final uid = _preferences.getString(_keyUid);
    if (uid != null && uid.isNotEmpty) {
      _currentUser = AppUser(
        uid: uid,
        email: _preferences.getString(_keyEmail) ?? 'user@aarogivya.com',
        displayName: _preferences.getString(_keyName) ?? 'Aarogivya User',
        role: UserRole.fromValue(_preferences.getString(_keyRole)),
        createdAt: DateTime.now(),
      );
    } else {
      _currentUser = null;
    }
    _controller.add(_currentUser);
  }

  Future<void> _persistUser(AppUser? user) async {
    _currentUser = user;
    if (user != null) {
      await _preferences.setString(_keyUid, user.uid);
      await _preferences.setString(_keyEmail, user.email);
      await _preferences.setString(_keyName, user.displayName);
      await _preferences.setString(_keyRole, user.role.value);
    } else {
      await _preferences.remove(_keyUid);
      await _preferences.remove(_keyEmail);
      await _preferences.remove(_keyName);
      await _preferences.remove(_keyRole);
    }
    _controller.add(_currentUser);
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<AppUser?> currentUser() async => _currentUser;

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw const AuthFailure('Email and password cannot be empty.');
    }

    final role = trimmedEmail.toLowerCase().contains('doctor')
        ? UserRole.doctor
        : UserRole.patient;

    final displayName = trimmedEmail.toLowerCase().contains('doctor')
        ? 'Dr. Demo Doctor'
        : 'Demo Patient';

    final user = AppUser(
      uid: 'user_${trimmedEmail.hashCode.abs()}',
      email: trimmedEmail,
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
    );

    await _persistUser(user);
    return user;
  }

  @override
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw const AuthFailure('Email and password cannot be empty.');
    }

    final user = AppUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: trimmedEmail,
      displayName: fullName.trim().isEmpty ? 'User' : fullName.trim(),
      role: role,
      createdAt: DateTime.now(),
    );

    await _persistUser(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle({required UserRole role}) async {
    final user = AppUser(
      uid: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      email: role == UserRole.doctor ? 'doctor@google.com' : 'patient@google.com',
      displayName: role == UserRole.doctor ? 'Dr. Google User' : 'Google Patient',
      role: role,
      createdAt: DateTime.now(),
    );

    await _persistUser(user);
    return user;
  }

  @override
  Future<AppUser> signInWithPhone({
    required String phoneNumber,
    required UserRole role,
    required Future<String> Function(String verificationId) smsCodeProvider,
  }) async {
    final user = AppUser(
      uid: 'phone_user_${phoneNumber.replaceAll(RegExp(r'\D'), '')}',
      email: '$phoneNumber@phone.aarogivya.com',
      displayName: role == UserRole.doctor ? 'Dr. Phone User' : 'Phone Patient',
      role: role,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );

    await _persistUser(user);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Local mock: success
  }

  @override
  Future<void> signOut() async {
    await _persistUser(null);
  }
}
