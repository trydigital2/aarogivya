import 'dart:async';
import 'package:aarogivya/features/patient/domain/entities/patient_profile.dart';
import 'package:aarogivya/features/records/domain/entities/medical_record.dart';
import 'package:aarogivya/features/records/domain/repositories/health_records_repository.dart';

class LocalHealthRecordsRepository implements HealthRecordsRepository {
  LocalHealthRecordsRepository() {
    _initRecords();
  }

  final _recordsController = StreamController<List<MedicalRecord>>.broadcast();
  final _profileController = StreamController<PatientProfile?>.broadcast();

  final List<MedicalRecord> _records = [];
  final Map<String, PatientProfile> _profiles = {};

  void _initRecords() {
    final now = DateTime.now();

    _records.addAll([
      MedicalRecord(
        id: 'rec_1',
        patientId: 'patient_default',
        title: 'Complete Blood Count (CBC)',
        type: MedicalRecordType.report,
        createdAt: now.subtract(const Duration(days: 10)),
        notes: 'Normal hemoglobin and white blood cell levels.',
        verified: true,
      ),
      MedicalRecord(
        id: 'rec_2',
        patientId: 'patient_default',
        title: 'Cardiac Prescription by Dr. Priya Sharma',
        type: MedicalRecordType.prescription,
        createdAt: now.subtract(const Duration(days: 5)),
        notes: 'Follow low sodium diet and take prescribed tablets regularly.',
        verified: true,
      ),
      MedicalRecord(
        id: 'rec_3',
        patientId: 'patient_default',
        title: 'Blood Pressure',
        type: MedicalRecordType.measurement,
        createdAt: now.subtract(const Duration(days: 1)),
        value: 120,
        unit: 'mmHg (Systolic)',
        notes: 'Resting BP measured in morning.',
      ),
      MedicalRecord(
        id: 'rec_4',
        patientId: 'patient_default',
        title: 'Fasting Blood Sugar',
        type: MedicalRecordType.measurement,
        createdAt: now.subtract(const Duration(days: 2)),
        value: 92,
        unit: 'mg/dL',
        notes: 'Fasting 10 hours.',
      ),
    ]);

    _profiles['patient_default'] = PatientProfile(
      userId: 'patient_default',
      bloodGroup: 'O+',
      allergies: const ['Penicillin', 'Peanuts'],
      medicalHistory: 'Mild seasonal allergies. No chronic conditions.',
      dateOfBirth: DateTime(1996, 5, 14),
      emergencyContact: '+91 98765 43210',
    );
  }

  @override
  Stream<List<MedicalRecord>> watchRecords(String patientId) async* {
    List<MedicalRecord> forPatient() {
      return _records
          .where((r) => r.patientId == patientId || r.patientId == 'patient_default')
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    yield forPatient();
    yield* _recordsController.stream.map((_) => forPatient());
  }

  @override
  Stream<PatientProfile?> watchPatientProfile(String patientId) async* {
    PatientProfile profile() {
      return _profiles[patientId] ??
          _profiles['patient_default'] ??
          PatientProfile(userId: patientId);
    }

    yield profile();
    yield* _profileController.stream.map((_) => profile());
  }

  @override
  Future<String> uploadRecord({
    required String patientId,
    required String title,
    required MedicalRecordType type,
    required String filePath,
    String? notes,
  }) async {
    final record = MedicalRecord(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      title: title,
      type: type,
      createdAt: DateTime.now(),
      fileUrl: filePath,
      notes: notes,
      verified: false,
    );
    _records.insert(0, record);
    _recordsController.add(_records);
    return record.id;
  }

  @override
  Future<void> addMeasurement({
    required String patientId,
    required String title,
    required num value,
    required String unit,
    String? notes,
  }) async {
    final record = MedicalRecord(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      title: title,
      type: MedicalRecordType.measurement,
      createdAt: DateTime.now(),
      value: value,
      unit: unit,
      notes: notes,
      verified: false,
    );
    _records.insert(0, record);
    _recordsController.add(_records);
  }

  @override
  Future<void> updatePatientProfile(PatientProfile profile) async {
    _profiles[profile.userId] = profile;
    _profileController.add(profile);
  }

  @override
  Future<void> setPrescriptionVerification({
    required String doctorId,
    required String patientId,
    required String recordId,
    required bool verified,
  }) async {
    final index = _records.indexWhere((r) => r.id == recordId);
    if (index >= 0) {
      final old = _records[index];
      _records[index] = MedicalRecord(
        id: old.id,
        patientId: old.patientId,
        title: old.title,
        type: old.type,
        createdAt: old.createdAt,
        fileUrl: old.fileUrl,
        notes: old.notes,
        value: old.value,
        unit: old.unit,
        verified: verified,
      );
      _recordsController.add(_records);
    }
  }
}
