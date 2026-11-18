import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = <AppointmentStatus, Color>{
      AppointmentStatus.pending: Colors.orange,
      AppointmentStatus.confirmed: Colors.green,
      AppointmentStatus.completed: Colors.blue,
      AppointmentStatus.cancelled: Colors.red,
    };
    final color = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AppointmentTile extends StatelessWidget {
  const AppointmentTile({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onReschedule,
    this.onConfirm,
    this.onDecline,
    this.showPatient = false,
  });

  final Appointment appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onConfirm;
  final VoidCallback? onDecline;
  final bool showPatient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    showPatient ? appointment.patientName : appointment.doctorName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                StatusChip(status: appointment.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              appointment.specialization.isEmpty
                  ? 'Consultation'
                  : appointment.specialization,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(AppFormatters.date(appointment.startsAt)),
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Text(AppFormatters.time(appointment.startsAt)),
              ],
            ),
            if (appointment.reason != null && appointment.reason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Reason: ${appointment.reason}'),
            ],
            if (onCancel != null || onReschedule != null || onConfirm != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (onConfirm != null)
                    FilledButton(
                      onPressed: onConfirm,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(80, 36),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Accept'),
                    ),
                  if (onDecline != null)
                    OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(80, 36),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Decline'),
                    ),
                  if (onReschedule != null)
                    OutlinedButton(
                      onPressed: onReschedule,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(80, 36),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Reschedule'),
                    ),
                  if (onCancel != null)
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
