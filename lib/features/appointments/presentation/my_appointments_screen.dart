import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';
import 'package:aarogivya/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:aarogivya/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/entities/availability_slot.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final repository = context.read<AppointmentRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('My appointments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.patientSearch),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Book visit'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Upcoming')),
                ButtonSegment(value: 1, label: Text('History')),
              ],
              selected: <int>{_tab},
              onSelectionChanged: (selection) =>
                  setState(() => _tab = selection.first),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Appointment>>(
              stream: repository.watchPatientAppointments(user.uid),
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
                      (appointment) => _tab == 0
                          ? appointment.isUpcoming
                          : !appointment.isUpcoming,
                    )
                    .toList();
                if (appointments.isEmpty) {
                  return EmptyView(
                    title: _tab == 0
                        ? 'No upcoming appointments'
                        : 'No appointment history',
                    message: _tab == 0
                        ? 'Find a doctor and book your first consultation.'
                        : 'Past and cancelled visits will appear here.',
                    icon: Icons.calendar_month_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    0,
                    AppSpacing.pageHorizontal,
                    100,
                  ),
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return AppointmentTile(
                      appointment: appointment,
                      onCancel: appointment.isUpcoming
                          ? () => _confirmCancel(appointment)
                          : null,
                      onReschedule: appointment.isUpcoming
                          ? () => _openReschedule(appointment)
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

  Future<void> _confirmCancel(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel appointment?'),
        content: Text(
          'Cancel your visit with ${appointment.doctorName} on ${AppFormatters.date(appointment.startsAt)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel visit'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context
          .read<AppointmentRepository>()
          .cancelAppointment(appointment.id);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _openReschedule(Appointment appointment) async {
    final date = await showDatePicker(
      context: context,
      initialDate: appointment.startsAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;

    if (!mounted) return;
    final slot = await showDialog<AvailabilitySlot>(
      context: context,
      builder: (dialogContext) => _SlotPickerDialog(
        doctorId: appointment.doctorId,
        date: date,
      ),
    );
    if (slot == null || !mounted) return;

    try {
      await context.read<AppointmentRepository>().rescheduleAppointment(
            appointmentId: appointment.id,
            newSlotId: slot.id,
          );
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mapFirebaseError(error).message)),
    );
  }
}

class _SlotPickerDialog extends StatelessWidget {
  const _SlotPickerDialog({required this.doctorId, required this.date});

  final String doctorId;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DoctorRepository>();
    return AlertDialog(
      title: Text('Choose a slot • ${AppFormatters.date(date)}'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<AvailabilitySlot>>(
          stream: repository.watchSlots(doctorId, date),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }
            final slots = (snapshot.data ?? const <AvailabilitySlot>[])
                .where((slot) => slot.isAvailable)
                .toList();
            if (slots.isEmpty) {
              return const EmptyView(
                title: 'No free slots',
                icon: Icons.event_busy_outlined,
              );
            }
            return Wrap(
              spacing: 8,
              children: slots
                  .map(
                    (slot) => ActionChip(
                      label: Text(AppFormatters.time(slot.startsAt)),
                      onPressed: () => Navigator.of(context).pop(slot),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
