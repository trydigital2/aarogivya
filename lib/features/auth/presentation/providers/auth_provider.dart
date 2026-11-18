import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:aarogivya/features/auth/domain/entities/app_user.dart';
import 'package:aarogivya/features/auth/domain/entities/user_role.dart';
import 'package:aarogivya/features/auth/domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository, {this.onBeforeSignOut});

  final AuthRepository _repository;
  final Future<void> Function()? onBeforeSignOut;
  StreamSubscription<AppUser?>? _subscription;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _isBusy = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  bool get isPatient => _user?.role == UserRole.patient;

  void startListening() {
    _subscription ??= _repository.authStateChanges().listen(
      (user) {
        _user = user;
        _status = user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated;
        notifyListeners();
      },
      onError: (_) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      },
    );
  }

  Future<bool> signIn(String email, String password) => _runAction(() {
        return _repository.signInWithEmail(
          email: email,
          password: password,
        );
      });

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) =>
      _runAction(() {
        return _repository.registerWithEmail(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
        );
      });

  Future<bool> signInWithGoogle(UserRole role) => _runAction(() {
        return _repository.signInWithGoogle(role: role);
      });

  Future<bool> signInWithPhone({
    required String phoneNumber,
    required UserRole role,
    required Future<String> Function(String verificationId) smsCodeProvider,
  }) =>
      _runAction(() {
        return _repository.signInWithPhone(
          phoneNumber: phoneNumber,
          role: role,
          smsCodeProvider: smsCodeProvider,
        );
      });

  Future<bool> sendPasswordReset(String email) => _runAction(() {
        return _repository.sendPasswordResetEmail(email);
      });

  Future<void> signOut() async {
    _setBusy(true);
    try {
      await onBeforeSignOut?.call();
      await _repository.signOut();
    } catch (error) {
      _setError(_readableError(error));
    } finally {
      _setBusy(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runAction(Future<Object?> Function() action) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      await action();
      return true;
    } catch (error) {
      _setError(_readableError(error));
      return false;
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  String _readableError(Object error) => error.toString().replaceFirst(
        RegExp(r'^[_A-Za-z]+\s*(exception|error):\s*', caseSensitive: false),
        '',
      );

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
