import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/core/widgets/profile_avatar.dart';
import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:aarogivya/features/records/domain/entities/medical_record.dart';
import 'package:aarogivya/features/records/domain/repositories/health_records_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DoctorPatientsScreen extends StatelessWidget {
  const DoctorPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final doctorRepository = context.read<DoctorRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      body: StreamBuilder<List<Appointment>>(
        stream: doctorRepository.watchDoctorAppointments(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(message: mapFirebaseError(snapshot.error!).message);
          }
          final patients = <String, String>{};
          for (final appointment in snapshot.data ?? const <Appointment>[]) {
            patients.putIfAbsent(appointment.patientId, () => appointment.patientName);
          }
          if (patients.isEmpty) {
            return const EmptyView(
              title: 'No patients yet',
              message: 'Patients appear after they book an appointment.',
              icon: Icons.people_outline_rounded,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = patients.entries.elementAt(index);
              return Card(
                child: ExpansionTile(
                  leading: ProfileAvatar(initials: _initials(entry.value)),
                  title: Text(entry.value),
                  subtitle: Text('Patient ID: ${entry.key.substring(0, 8)}'),
                  children: [
                    _PrescriptionList(
                      patientId: entry.key,
                      doctorId: user.uid,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _initials(String name) => name
      .split(' ')
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}

class _PrescriptionList extends StatelessWidget {
  const _PrescriptionList({required this.patientId, required this.doctorId});

  final String patientId;
  final String doctorId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<HealthRecordsRepository>();
    return StreamBuilder<List<MedicalRecord>>(
      stream: repository.watchRecords(patientId),
      builder: (context, snapshot) {
        final prescriptions = (snapshot.data ?? const <MedicalRecord>[])
            .where((record) => record.type == MedicalRecordType.prescription)
            .toList();
        if (prescriptions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No prescriptions shared.'),
          );
        }
        return Column(
          children: [
            for (final record in prescriptions)
              ListTile(
                title: Text(record.title),
                subtitle: Text(record.verified ? 'Verified' : 'Awaiting verification'),
                trailing: record.verified
                    ? const Icon(Icons.verified_rounded, color: Colors.green)
                    : TextButton(
                        onPressed: () => repository.setPrescriptionVerification(
                          doctorId: doctorId,
                          patientId: patientId,
                          recordId: record.id,
                          verified: true,
                        ),
                        child: const Text('Verify'),
                      ),
              ),
          ],
        );
      },
    );
  }
}
