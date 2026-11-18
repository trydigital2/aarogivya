import 'package:aarogivya/core/utils/firestore_values.dart';

class DoctorProfile {
  const DoctorProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.specialization,
    required this.qualifications,
    required this.experienceYears,
    required this.consultationFee,
    required this.city,
    required this.isAcceptingPatients,
    this.photoUrl,
    this.clinicName,
    this.about,
    this.rating = 0,
    this.reviewCount = 0,
    this.languages = const <String>[],
  });

  final String id;
  final String userId;
  final String fullName;
  final String specialization;
  final List<String> qualifications;
  final int experienceYears;
  final num consultationFee;
  final String city;
  final bool isAcceptingPatients;
  final String? photoUrl;
  final String? clinicName;
  final String? about;
  final double rating;
  final int reviewCount;
  final List<String> languages;

  factory DoctorProfile.fromMap(String id, Map<String, dynamic> map) {
    return DoctorProfile(
      id: id,
      userId: FirestoreValues.string(map['userId']),
      fullName: FirestoreValues.string(map['fullName'], 'Doctor'),
      specialization: FirestoreValues.string(map['specialization'], 'General'),
      qualifications: FirestoreValues.stringList(map['qualifications']),
      experienceYears: FirestoreValues.number(map['experienceYears']).toInt(),
      consultationFee: FirestoreValues.number(map['consultationFee']),
      city: FirestoreValues.string(map['city']),
      isAcceptingPatients: FirestoreValues.boolean(map['isAcceptingPatients'], true),
      photoUrl: map['photoUrl'] as String?,
      clinicName: map['clinicName'] as String?,
      about: map['about'] as String?,
      rating: FirestoreValues.number(map['rating']).toDouble(),
      reviewCount: FirestoreValues.number(map['reviewCount']).toInt(),
      languages: FirestoreValues.stringList(map['languages']),
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userId': userId,
        'fullName': fullName,
        'specialization': specialization,
        'qualifications': qualifications,
        'experienceYears': experienceYears,
        'consultationFee': consultationFee,
        'city': city,
        'isAcceptingPatients': isAcceptingPatients,
        'photoUrl': photoUrl,
        'clinicName': clinicName,
        'about': about,
        'languages': languages,
      };
}
