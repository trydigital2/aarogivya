import 'package:aarogivya/core/utils/firestore_values.dart';

enum AppointmentStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled');

  const AppointmentStatus(this.label);

  final String label;

  static AppointmentStatus fromValue(String? value) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AppointmentStatus.pending,
    );
  }
}

class Appointment {
  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.specialization,
    required this.startsAt,
    required this.status,
    this.reason,
    this.fee = 0,
    this.slotId,
    this.doctorPhotoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String specialization;
  final DateTime startsAt;
  final AppointmentStatus status;
  final String? reason;
  final num fee;
  final String? slotId;
  final String? doctorPhotoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      patientId: FirestoreValues.string(map['patientId']),
      doctorId: FirestoreValues.string(map['doctorId']),
      patientName: FirestoreValues.string(map['patientName'], 'Patient'),
      doctorName: FirestoreValues.string(map['doctorName'], 'Doctor'),
      specialization: FirestoreValues.string(map['specialization']),
      startsAt: FirestoreValues.date(map['startsAt']),
      status: AppointmentStatus.fromValue(map['status'] as String?),
      reason: map['reason'] as String?,
      fee: FirestoreValues.number(map['fee']),
      slotId: map['slotId'] as String?,
      doctorPhotoUrl: map['doctorPhotoUrl'] as String?,
      createdAt: FirestoreValues.optionalDate(map['createdAt']),
      updatedAt: FirestoreValues.optionalDate(map['updatedAt']),
    );
  }

  bool get isUpcoming =>
      startsAt.isAfter(DateTime.now()) &&
      (status == AppointmentStatus.pending ||
          status == AppointmentStatus.confirmed);
}
