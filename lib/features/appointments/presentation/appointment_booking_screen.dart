import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/app_button.dart';
import 'package:aarogivya/core/widgets/app_text_field.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/entities/availability_slot.dart';
import 'package:aarogivya/features/doctor/domain/entities/doctor_profile.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({
    super.key,
    required this.doctorId,
  });

  final String doctorId;

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  DateTime _selectedDay = DateTime.now();
  AvailabilitySlot? _selectedSlot;
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year, now.month, now.day + 60),
    );
    if (date == null) return;
    setState(() {
      _selectedDay = date;
      _selectedSlot = null;
    });
  }

  Future<void> _book() async {
    final slot = _selectedSlot;
    if (slot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an available slot.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await context.read<AppointmentRepository>().bookAppointment(
            patientId: context.read<AuthProvider>().user!.uid,
            doctorId: widget.doctorId,
            slotId: slot.id,
            reason: _reasonController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment requested successfully.')),
      );
      context.go(AppRoutes.patientAppointments);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFirebaseError(error).message)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorRepository = context.read<DoctorRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: AppButton(
            label: 'Request appointment',
            icon: Icons.check_circle_outline_rounded,
            isLoading: _isSubmitting,
            onPressed: _book,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<DoctorProfile?>(
              stream: doctorRepository.watchDoctor(widget.doctorId),
              builder: (context, snapshot) {
                final doctor = snapshot.data;
                if (doctor == null) return const SizedBox.shrink();
                return Card(
                  child: ListTile(
                    title: Text(doctor.fullName),
                    subtitle: Text(
                      '${doctor.specialization} • ${AppFormatters.currency(doctor.consultationFee)}',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Appointment date'),
                subtitle: Text(AppFormatters.date(_selectedDay)),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Available slots',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<AvailabilitySlot>>(
              stream: doctorRepository.watchSlots(widget.doctorId, _selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView();
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: mapFirebaseError(snapshot.error!).message,
                  );
                }
                final slots = snapshot.data ?? const <AvailabilitySlot>[];
                if (slots.isEmpty) {
                  return const EmptyView(
                    title: 'No slots for this date',
                    message: 'Choose another date or ask the doctor to add slots.',
                    icon: Icons.event_busy_outlined,
                  );
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: slots.map((slot) {
                    final selected = slot.id == _selectedSlot?.id;
                    return ChoiceChip(
                      label: Text(AppFormatters.time(slot.startsAt)),
                      selected: selected,
                      disabledColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      labelStyle: TextStyle(
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                      showCheckmark: false,
                      onSelected: slot.isAvailable
                          ? (value) => setState(
                              () => _selectedSlot = value ? slot : null,
                            )
                          : null,
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Reason for visit (optional)',
              controller: _reasonController,
              hint: 'Briefly describe your symptoms',
              prefixIcon: Icons.note_alt_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
