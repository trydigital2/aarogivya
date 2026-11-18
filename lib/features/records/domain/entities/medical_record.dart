import 'package:aarogivya/core/utils/firestore_values.dart';

enum MedicalRecordType { report, prescription, measurement, note }

class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.patientId,
    required this.title,
    required this.type,
    required this.createdAt,
    this.fileUrl,
    this.notes,
    this.value,
    this.unit,
    this.verified = false,
  });

  final String id;
  final String patientId;
  final String title;
  final MedicalRecordType type;
  final DateTime createdAt;
  final String? fileUrl;
  final String? notes;
  final num? value;
  final String? unit;
  final bool verified;

  factory MedicalRecord.fromMap(String id, Map<String, dynamic> map) {
    return MedicalRecord(
      id: id,
      patientId: FirestoreValues.string(map['patientId']),
      title: FirestoreValues.string(map['title'], 'Record'),
      type: MedicalRecordType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => MedicalRecordType.report,
      ),
      createdAt: FirestoreValues.date(map['createdAt']),
      fileUrl: map['fileUrl'] as String?,
      notes: map['notes'] as String?,
      value: map['value'] is num ? map['value'] as num : null,
      unit: map['unit'] as String?,
      verified: FirestoreValues.boolean(map['verified']),
    );
  }
}
