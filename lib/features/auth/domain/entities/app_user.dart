import 'package:aarogivya/features/auth/domain/entities/user_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
    this.fcmTokens = const <String>[],
  });

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;
  final List<String> fcmTokens;

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    List<String>? fcmTokens,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}
