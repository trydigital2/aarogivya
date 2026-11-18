import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';
import 'package:aarogivya/features/doctor/domain/entities/availability_slot.dart';
import 'package:aarogivya/features/doctor/domain/entities/doctor_profile.dart';

abstract interface class DoctorRepository {
  Stream<List<DoctorProfile>> watchDoctors({String? specialization, String? search});

  Stream<DoctorProfile?> watchDoctor(String doctorId);

  Stream<List<Appointment>> watchDoctorAppointments(String doctorId);

  Stream<List<AvailabilitySlot>> watchSlots(String doctorId, DateTime day);

  Future<void> saveProfile(DoctorProfile profile);

  Future<String> uploadProfileImage(String doctorId, String filePath);

  Future<void> addSlot({
    required String doctorId,
    required DateTime startsAt,
    Duration duration = const Duration(minutes: 30),
  });

  Future<void> deleteSlot({required String doctorId, required String slotId});

  Future<void> respondToAppointment({
    required String appointmentId,
    required bool accept,
  });
}
