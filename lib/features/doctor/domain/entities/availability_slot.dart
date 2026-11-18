import 'package:aarogivya/core/utils/firestore_values.dart';

class AvailabilitySlot {
  const AvailabilitySlot({
    required this.id,
    required this.doctorId,
    required this.startsAt,
    required this.endsAt,
    required this.isAvailable,
    this.appointmentId,
  });

  final String id;
  final String doctorId;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isAvailable;
  final String? appointmentId;

  factory AvailabilitySlot.fromMap(String id, Map<String, dynamic> map) {
    return AvailabilitySlot(
      id: id,
      doctorId: FirestoreValues.string(map['doctorId']),
      startsAt: FirestoreValues.date(map['startsAt']),
      endsAt: FirestoreValues.date(map['endsAt']),
      isAvailable: FirestoreValues.boolean(map['isAvailable']),
      appointmentId: map['appointmentId'] as String?,
    );
  }
}
