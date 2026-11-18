import 'dart:async';
import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';
import 'package:aarogivya/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:aarogivya/data/local/local_doctor_repository.dart';

class LocalAppointmentRepository implements AppointmentRepository {
  LocalAppointmentRepository(this._doctorRepository) {
    _initSampleAppointments();
  }

  final LocalDoctorRepository _doctorRepository;
  final _appointmentsController = StreamController<List<Appointment>>.broadcast();
  final List<Appointment> _appointments = [];

  void _initSampleAppointments() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 4));

    final sample1 = Appointment(
      id: 'appt_1',
      patientId: 'patient_default',
      doctorId: 'doc_1',
      patientName: 'Demo Patient',
      doctorName: 'Dr. Priya Sharma',
      specialization: 'Cardiologist',
      startsAt: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
      status: AppointmentStatus.confirmed,
      reason: 'Routine cardiac health checkup',
      fee: 800,
      createdAt: now.subtract(const Duration(days: 1)),
    );

    final sample2 = Appointment(
      id: 'appt_2',
      patientId: 'patient_default',
      doctorId: 'doc_2',
      patientName: 'Demo Patient',
      doctorName: 'Dr. Rajesh Kumar',
      specialization: 'General Physician',
      startsAt: DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 14, 30),
      status: AppointmentStatus.pending,
      reason: 'Seasonal allergy consultation',
      fee: 500,
      createdAt: now,
    );

    _appointments.addAll([sample1, sample2]);
    _doctorRepository.addAppointment(sample1);
    _doctorRepository.addAppointment(sample2);
  }

  @override
  Stream<List<Appointment>> watchPatientAppointments(String patientId) async* {
    List<Appointment> forPatient() {
      return _appointments
          .where((a) => a.patientId == patientId || a.patientId == 'patient_default')
          .toList()
        ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    }

    yield forPatient();
    yield* _appointmentsController.stream.map((_) => forPatient());
  }

  @override
  Stream<Appointment?> watchAppointment(String appointmentId) async* {
    Appointment? find() {
      try {
        return _appointments.firstWhere((a) => a.id == appointmentId);
      } catch (_) {
        return null;
      }
    }

    yield find();
    yield* _appointmentsController.stream.map((_) => find());
  }

  @override
  Future<void> bookAppointment({
    required String patientId,
    required String doctorId,
    required String slotId,
    required String reason,
  }) async {
    final doctor = _doctorRepository.getDoctorById(doctorId);
    final doctorName = doctor?.fullName ?? 'Doctor';
    final specialization = doctor?.specialization ?? 'General';
    final fee = doctor?.consultationFee ?? 500;

    final appointment = Appointment(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      doctorId: doctorId,
      patientName: 'Patient',
      doctorName: doctorName,
      specialization: specialization,
      startsAt: DateTime.now().add(const Duration(days: 1)),
      status: AppointmentStatus.confirmed,
      reason: reason,
      fee: fee,
      slotId: slotId,
      createdAt: DateTime.now(),
    );

    _appointments.add(appointment);
    _doctorRepository.addAppointment(appointment);
    _appointmentsController.add(_appointments);
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index >= 0) {
      final old = _appointments[index];
      final updated = Appointment(
        id: old.id,
        patientId: old.patientId,
        doctorId: old.doctorId,
        patientName: old.patientName,
        doctorName: old.doctorName,
        specialization: old.specialization,
        startsAt: old.startsAt,
        status: AppointmentStatus.cancelled,
        reason: old.reason,
        fee: old.fee,
        slotId: old.slotId,
        doctorPhotoUrl: old.doctorPhotoUrl,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      _appointments[index] = updated;
      _appointmentsController.add(_appointments);
    }
  }

  @override
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required String newSlotId,
  }) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index >= 0) {
      final old = _appointments[index];
      final updated = Appointment(
        id: old.id,
        patientId: old.patientId,
        doctorId: old.doctorId,
        patientName: old.patientName,
        doctorName: old.doctorName,
        specialization: old.specialization,
        startsAt: old.startsAt.add(const Duration(days: 1)),
        status: AppointmentStatus.confirmed,
        reason: old.reason,
        fee: old.fee,
        slotId: newSlotId,
        doctorPhotoUrl: old.doctorPhotoUrl,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      _appointments[index] = updated;
      _appointmentsController.add(_appointments);
    }
  }
}
