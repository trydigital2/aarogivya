import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';

abstract interface class AppointmentRepository {
  Stream<List<Appointment>> watchPatientAppointments(String patientId);

  Stream<Appointment?> watchAppointment(String appointmentId);

  Future<void> bookAppointment({
    required String patientId,
    required String doctorId,
    required String slotId,
    required String reason,
  });

  Future<void> cancelAppointment(String appointmentId);

  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String newSlotId,
  });
}
