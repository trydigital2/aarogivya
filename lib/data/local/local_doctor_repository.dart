import 'dart:async';
import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';
import 'package:aarogivya/features/doctor/domain/entities/availability_slot.dart';
import 'package:aarogivya/features/doctor/domain/entities/doctor_profile.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';

class LocalDoctorRepository implements DoctorRepository {
  LocalDoctorRepository() {
    _initDoctors();
  }

  final _doctorsController = StreamController<List<DoctorProfile>>.broadcast();
  final _appointmentsController = StreamController<List<Appointment>>.broadcast();
  final _slotsController = StreamController<List<AvailabilitySlot>>.broadcast();

  final List<DoctorProfile> _doctors = [];
  final List<Appointment> _doctorAppointments = [];
  final List<AvailabilitySlot> _slots = [];

  void _initDoctors() {
    _doctors.addAll([
      const DoctorProfile(
        id: 'doc_1',
        userId: 'user_doc_1',
        fullName: 'Dr. Priya Sharma',
        specialization: 'Cardiologist',
        qualifications: ['MBBS', 'MD (Cardiology)', 'FACC'],
        experienceYears: 12,
        consultationFee: 800,
        city: 'Mumbai',
        isAcceptingPatients: true,
        clinicName: 'Heart Care Clinic',
        about: 'Senior Consultant Cardiologist specializing in preventive cardiology and heart rhythm management.',
        rating: 4.9,
        reviewCount: 142,
        languages: ['English', 'Hindi', 'Marathi'],
      ),
      const DoctorProfile(
        id: 'doc_2',
        userId: 'user_doc_2',
        fullName: 'Dr. Rajesh Kumar',
        specialization: 'General Physician',
        qualifications: ['MBBS', 'MD (Internal Medicine)'],
        experienceYears: 9,
        consultationFee: 500,
        city: 'Bengaluru',
        isAcceptingPatients: true,
        clinicName: 'City Health Care',
        about: 'Experienced internal medicine physician focused on holistic wellness, lifestyle disorders, and chronic disease management.',
        rating: 4.8,
        reviewCount: 98,
        languages: ['English', 'Hindi', 'Kannada'],
      ),
      const DoctorProfile(
        id: 'doc_3',
        userId: 'user_doc_3',
        fullName: 'Dr. Ananya Iyer',
        specialization: 'Pediatrician',
        qualifications: ['MBBS', 'DCH', 'DNB (Pediatrics)'],
        experienceYears: 14,
        consultationFee: 700,
        city: 'Delhi',
        isAcceptingPatients: true,
        clinicName: 'Little Smiles Child Clinic',
        about: 'Caring pediatrician passionate about child nutrition, developmental milestones, and routine immunization.',
        rating: 4.9,
        reviewCount: 210,
        languages: ['English', 'Hindi', 'Tamil'],
      ),
      const DoctorProfile(
        id: 'doc_4',
        userId: 'user_doc_4',
        fullName: 'Dr. Suresh Patel',
        specialization: 'Dermatologist',
        qualifications: ['MBBS', 'DVD', 'MD (Dermatology)'],
        experienceYears: 11,
        consultationFee: 650,
        city: 'Ahmedabad',
        isAcceptingPatients: true,
        clinicName: 'Aura Skin Clinic',
        about: 'Expert dermatologist handling clinical dermatology, acne treatments, hair care, and aesthetic dermatology.',
        rating: 4.7,
        reviewCount: 76,
        languages: ['English', 'Hindi', 'Gujarati'],
      ),
      const DoctorProfile(
        id: 'doc_5',
        userId: 'user_doc_5',
        fullName: 'Dr. Vikram Malhotra',
        specialization: 'Orthopedic',
        qualifications: ['MBBS', 'MS (Orthopedics)'],
        experienceYears: 16,
        consultationFee: 900,
        city: 'Pune',
        isAcceptingPatients: true,
        clinicName: 'Bone & Joint Institute',
        about: 'Orthopedic specialist in joint preservation, sports injury rehabilitation, and arthroscopy.',
        rating: 4.8,
        reviewCount: 165,
        languages: ['English', 'Hindi', 'Marathi'],
      ),
    ]);
  }

  List<AvailabilitySlot> _getGeneratedSlots(String doctorId, DateTime day) {
    // Generate default available slots for the given day if none exist
    final existing = _slots.where((s) {
      return s.doctorId == doctorId &&
          s.startsAt.year == day.year &&
          s.startsAt.month == day.month &&
          s.startsAt.day == day.day;
    }).toList();

    if (existing.isNotEmpty) return existing;

    final baseSlots = <AvailabilitySlot>[];
    final hours = [9, 10, 11, 14, 15, 16, 17];
    for (var i = 0; i < hours.length; i++) {
      final hour = hours[i];
      final start = DateTime(day.year, day.month, day.day, hour, 0);
      final end = start.add(const Duration(minutes: 30));
      final slot = AvailabilitySlot(
        id: 'slot_${doctorId}_${day.year}_${day.month}_${day.day}_$hour',
        doctorId: doctorId,
        startsAt: start,
        endsAt: end,
        isAvailable: true,
      );
      baseSlots.add(slot);
      _slots.add(slot);
    }
    return baseSlots;
  }

  @override
  Stream<List<DoctorProfile>> watchDoctors({String? specialization, String? search}) async* {
    List<DoctorProfile> filter(List<DoctorProfile> list) {
      return list.where((doc) {
        if (specialization != null &&
            specialization.isNotEmpty &&
            specialization.toLowerCase() != 'all' &&
            doc.specialization.toLowerCase() != specialization.toLowerCase()) {
          return false;
        }
        if (search != null && search.isNotEmpty) {
          final query = search.toLowerCase();
          final matchesName = doc.fullName.toLowerCase().contains(query);
          final matchesSpec = doc.specialization.toLowerCase().contains(query);
          final matchesCity = doc.city.toLowerCase().contains(query);
          if (!matchesName && !matchesSpec && !matchesCity) return false;
        }
        return true;
      }).toList();
    }

    yield filter(_doctors);
    yield* _doctorsController.stream.map(filter);
  }

  @override
  Stream<DoctorProfile?> watchDoctor(String doctorId) async* {
    DoctorProfile? find() {
      try {
        return _doctors.firstWhere(
          (d) => d.id == doctorId || d.userId == doctorId,
        );
      } catch (_) {
        return null;
      }
    }

    yield find();
    yield* _doctorsController.stream.map((_) => find());
  }

  @override
  Stream<List<Appointment>> watchDoctorAppointments(String doctorId) async* {
    List<Appointment> forDoctor() {
      return _doctorAppointments
          .where((a) => a.doctorId == doctorId)
          .toList();
    }

    yield forDoctor();
    yield* _appointmentsController.stream.map((_) => forDoctor());
  }

  @override
  Stream<List<AvailabilitySlot>> watchSlots(String doctorId, DateTime day) async* {
    yield _getGeneratedSlots(doctorId, day);
    yield* _slotsController.stream.map((_) => _getGeneratedSlots(doctorId, day));
  }

  @override
  Future<void> saveProfile(DoctorProfile profile) async {
    final index = _doctors.indexWhere((d) => d.id == profile.id || d.userId == profile.userId);
    if (index >= 0) {
      _doctors[index] = profile;
    } else {
      _doctors.add(profile);
    }
    _doctorsController.add(_doctors);
  }

  @override
  Future<String> uploadProfileImage(String doctorId, String filePath) async {
    return filePath;
  }

  @override
  Future<void> addSlot({
    required String doctorId,
    required DateTime startsAt,
    Duration duration = const Duration(minutes: 30),
  }) async {
    final slot = AvailabilitySlot(
      id: 'slot_${DateTime.now().millisecondsSinceEpoch}',
      doctorId: doctorId,
      startsAt: startsAt,
      endsAt: startsAt.add(duration),
      isAvailable: true,
    );
    _slots.add(slot);
    _slotsController.add(_slots);
  }

  @override
  Future<void> deleteSlot({required String doctorId, required String slotId}) async {
    _slots.removeWhere((s) => s.id == slotId && s.doctorId == doctorId);
    _slotsController.add(_slots);
  }

  @override
  Future<void> respondToAppointment({
    required String appointmentId,
    required bool accept,
  }) async {
    final index = _doctorAppointments.indexWhere((a) => a.id == appointmentId);
    if (index >= 0) {
      final appt = _doctorAppointments[index];
      _doctorAppointments[index] = Appointment(
        id: appt.id,
        patientId: appt.patientId,
        doctorId: appt.doctorId,
        patientName: appt.patientName,
        doctorName: appt.doctorName,
        specialization: appt.specialization,
        startsAt: appt.startsAt,
        status: accept ? AppointmentStatus.confirmed : AppointmentStatus.cancelled,
        reason: appt.reason,
        fee: appt.fee,
        slotId: appt.slotId,
        doctorPhotoUrl: appt.doctorPhotoUrl,
        createdAt: appt.createdAt,
        updatedAt: DateTime.now(),
      );
      _appointmentsController.add(_doctorAppointments);
    }
  }

  void addAppointment(Appointment appointment) {
    _doctorAppointments.add(appointment);
    _appointmentsController.add(_doctorAppointments);
  }

  DoctorProfile? getDoctorById(String doctorId) {
    try {
      return _doctors.firstWhere((d) => d.id == doctorId || d.userId == doctorId);
    } catch (_) {
      return null;
    }
  }
}
