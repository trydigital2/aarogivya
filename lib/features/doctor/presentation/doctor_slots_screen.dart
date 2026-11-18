import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/entities/availability_slot.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DoctorSlotsScreen extends StatefulWidget {
  const DoctorSlotsScreen({super.key});

  @override
  State<DoctorSlotsScreen> createState() => _DoctorSlotsScreenState();
}

class _DoctorSlotsScreenState extends State<DoctorSlotsScreen> {
  DateTime _selectedDay = DateTime.now();

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year, now.month, now.day + 60),
    );
    if (date != null) setState(() => _selectedDay = date);
  }

  Future<void> _addSlot(String doctorId) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    final startsAt = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      time.hour,
      time.minute,
    );
    if (startsAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a future time.')),
      );
      return;
    }
    try {
      await context.read<DoctorRepository>().addSlot(
            doctorId: doctorId,
            startsAt: startsAt,
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final repository = context.read<DoctorRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSlot(user.uid),
        icon: const Icon(Icons.add),
        label: const Text('Add slot'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Selected date'),
                subtitle: Text(AppFormatters.date(_selectedDay)),
                trailing: TextButton(
                  onPressed: _pickDay,
                  child: const Text('Change'),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AvailabilitySlot>>(
              stream: repository.watchSlots(user.uid, _selectedDay),
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
                    message: 'Add a slot to let patients book a consultation.',
                    icon: Icons.schedule_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: slots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(slot.isAvailable
                              ? Icons.event_available_outlined
                              : Icons.event_busy_outlined),
                        ),
                        title: Text(AppFormatters.time(slot.startsAt)),
                        subtitle: Text(
                          slot.isAvailable
                              ? 'Available'
                              : 'Booked • ${slot.appointmentId ?? ''}',
                        ),
                        trailing: slot.isAvailable
                            ? IconButton(
                                onPressed: () async {
                                  try {
                                    await repository.deleteSlot(
                                      doctorId: user.uid,
                                      slotId: slot.id,
                                    );
                                  } catch (error) {
                                    _showError(error);
                                  }
                                },
                                icon: const Icon(Icons.delete_outline),
                              )
                            : null,
                      ),
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
}
