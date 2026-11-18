import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';
import 'package:aarogivya/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/entities/doctor_profile.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final doctorRepository = context.read<DoctorRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text('Dr. ${user.displayName}'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.go(AppRoutes.patientNotifications),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        children: [
          StreamBuilder<DoctorProfile?>(
            stream: doctorRepository.watchDoctor(user.uid),
            builder: (context, snapshot) {
              final doctor = snapshot.data;
              if (doctor == null) return const SizedBox.shrink();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(Icons.verified_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.isAcceptingPatients
                                  ? 'Accepting patients'
                                  : 'Profile not published',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${doctor.specialization} • ${AppFormatters.currency(doctor.consultationFee)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.go(AppRoutes.doctorProfileEdit),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          StreamBuilder<List<Appointment>>(
            stream: doctorRepository.watchDoctorAppointments(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView();
              }
              if (snapshot.hasError) {
                return ErrorView(
                  message: mapFirebaseError(snapshot.error!).message,
                );
              }
              final appointments = snapshot.data ?? const <Appointment>[];
              final pending = appointments
                  .where((item) => item.status.name == 'pending')
                  .length;
              final today = appointments.where((item) {
                final now = DateTime.now();
                return item.startsAt.year == now.year &&
                    item.startsAt.month == now.month &&
                    item.startsAt.day == now.day;
              }).length;
              return Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pending_actions_outlined,
                      label: 'Pending',
                      value: '$pending',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.today_outlined,
                      label: 'Today',
                      value: '$today',
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.event_available_outlined,
                      label: 'Total',
                      value: '${appointments.length}',
                      color: Colors.blue,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.event_note_outlined,
                  label: 'Requests',
                  onTap: () => context.go(AppRoutes.doctorAppointments),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionTile(
                  icon: Icons.schedule_outlined,
                  label: 'Slots',
                  onTap: () => context.go(AppRoutes.doctorSlots),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.people_outline_rounded,
                  label: 'Patients',
                  onTap: () => context.go(AppRoutes.doctorPatients),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionTile(
                  icon: Icons.badge_outlined,
                  label: 'Profile',
                  onTap: () => context.go(AppRoutes.doctorProfileEdit),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest requests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.doctorAppointments),
                child: const Text('View all'),
              ),
            ],
          ),
          StreamBuilder<List<Appointment>>(
            stream: doctorRepository.watchDoctorAppointments(user.uid),
            builder: (context, snapshot) {
              final requests = (snapshot.data ?? const <Appointment>[])
                  .where((item) => item.status.name == 'pending')
                  .take(2)
                  .toList();
              if (requests.isEmpty) {
                return const EmptyView(
                  title: 'No pending requests',
                  icon: Icons.notifications_none_rounded,
                );
              }
              return Column(
                children: [
                  for (final appointment in requests)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppointmentTile(
                        appointment: appointment,
                        showPatient: true,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 14),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
