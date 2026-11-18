import 'package:aarogivya/features/patient/domain/entities/patient_profile.dart';
import 'package:aarogivya/features/records/domain/entities/medical_record.dart';

abstract interface class HealthRecordsRepository {
  Stream<List<MedicalRecord>> watchRecords(String patientId);

  Stream<PatientProfile?> watchPatientProfile(String patientId);

  Future<String> uploadRecord({
    required String patientId,
    required String title,
    required MedicalRecordType type,
    required String filePath,
    String? notes,
  });

  Future<void> addMeasurement({
    required String patientId,
    required String title,
    required num value,
    required String unit,
    String? notes,
  });

  Future<void> updatePatientProfile(PatientProfile profile);

  Future<void> setPrescriptionVerification({
    required String doctorId,
    required String patientId,
    required String recordId,
    required bool verified,
  });
}
