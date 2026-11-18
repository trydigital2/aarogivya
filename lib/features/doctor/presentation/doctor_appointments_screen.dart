import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';
import 'package:aarogivya/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final repository = context.read<DoctorRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment requests')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Pending')),
                ButtonSegment(value: 1, label: Text('All')),
              ],
              selected: <int>{_tab},
              onSelectionChanged: (selection) =>
                  setState(() => _tab = selection.first),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: repository.watchDoctorAppointments(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView();
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: mapFirebaseError(snapshot.error!).message,
                  );
                }
                final appointments = (snapshot.data ?? const <Appointment>[])
                    .where(
                      (item) => _tab == 0
                          ? item.status.name == 'pending'
                          : true,
                    )
                    .toList();
                if (appointments.isEmpty) {
                  return const EmptyView(
                    title: 'No requests',
                    message: 'New patient requests will appear here.',
                    icon: Icons.event_note_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return AppointmentTile(
                      appointment: appointment,
                      showPatient: true,
                      onConfirm: appointment.status.name == 'pending'
                          ? () => _respond(appointment, true)
                          : null,
                      onDecline: appointment.status.name == 'pending'
                          ? () => _respond(appointment, false)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _respond(Appointment appointment, bool accept) async {
    try {
      await context.read<DoctorRepository>().respondToAppointment(
            appointmentId: appointment.id,
            accept: accept,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFirebaseError(error).message)),
      );
    }
  }
}
