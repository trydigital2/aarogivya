import 'package:aarogivya/core/utils/firestore_values.dart';

class PatientProfile {
  const PatientProfile({
    required this.userId,
    this.allergies = const <String>[],
    this.medicalHistory = '',
    this.bloodGroup = '',
    this.dateOfBirth,
    this.emergencyContact,
  });

  final String userId;
  final List<String> allergies;
  final String medicalHistory;
  final String bloodGroup;
  final DateTime? dateOfBirth;
  final String? emergencyContact;

  factory PatientProfile.fromMap(String userId, Map<String, dynamic> map) {
    return PatientProfile(
      userId: userId,
      allergies: FirestoreValues.stringList(map['allergies']),
      medicalHistory: FirestoreValues.string(map['medicalHistory']),
      bloodGroup: FirestoreValues.string(map['bloodGroup']),
      dateOfBirth: FirestoreValues.optionalDate(map['dateOfBirth']),
      emergencyContact: map['emergencyContact'] as String?,
    );
  }
}
