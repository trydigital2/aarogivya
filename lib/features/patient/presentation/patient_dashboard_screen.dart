import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/core/widgets/profile_avatar.dart';
import 'package:aarogivya/core/widgets/section_header.dart';
import 'package:aarogivya/features/appointments/domain/entities/appointment.dart';
import 'package:aarogivya/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:aarogivya/features/appointments/presentation/widgets/appointment_tile.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/entities/doctor_profile.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:aarogivya/features/doctor/presentation/widgets/doctor_card.dart';
import 'package:aarogivya/features/medicines/domain/entities/medicine.dart';
import 'package:aarogivya/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:aarogivya/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    final firstName = user.displayName.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_greeting()},',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(firstName),
          ],
        ),
        actions: [
          _NotificationIcon(userId: user.uid),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ProfileAvatar(
              imageUrl: user.photoUrl,
              initials: AppFormatters.initials(user.displayName),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => context.go(AppRoutes.patientHome),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          children: [
            _SearchBanner(),
            const SizedBox(height: AppSpacing.xl),
            _QuickActions(userId: user.uid),
            const SizedBox(height: AppSpacing.xl),
            _UpcomingAppointments(patientId: user.uid),
            const SizedBox(height: AppSpacing.xl),
            _TopDoctors(),
            const SizedBox(height: AppSpacing.xl),
            _NearbyClinics(),
            const SizedBox(height: AppSpacing.xl),
            _MedicinesSection(),
            const SizedBox(height: AppSpacing.xl),
            _HealthTip(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<NotificationRepository>();
    return StreamBuilder<List>(
      stream: repository.watchNotifications(userId),
      builder: (context, snapshot) {
        final unread = snapshot.data?.where((item) => !item.isRead).length ?? 0;
        return IconButton(
          onPressed: () => context.go(AppRoutes.patientNotifications),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            child: const Icon(Icons.notifications_none_rounded),
          ),
        );
      },
    );
  }
}

class _SearchBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.go(AppRoutes.patientSearch),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety_outlined,
                    color: Colors.white.withValues(alpha: 0.9)),
                const SizedBox(width: 8),
                Text(
                  'How can we help today?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Text(
                    'Search doctors, specialists, clinics...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.calendar_month_outlined,
        label: 'Book visit',
        color: Colors.blue,
        onTap: () => context.go(AppRoutes.patientSearch),
      ),
      _QuickAction(
        icon: Icons.folder_shared_outlined,
        label: 'Records',
        color: Colors.teal,
        onTap: () => context.go(AppRoutes.patientRecords),
      ),
      _QuickAction(
        icon: Icons.medication_outlined,
        label: 'Medicines',
        color: Colors.purple,
        onTap: () => context.go(AppRoutes.patientMedicines),
      ),
      _QuickAction(
        icon: Icons.local_pharmacy_outlined,
        label: 'Orders',
        color: Colors.orange,
        onTap: () => context.go(AppRoutes.patientOrders),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick actions'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 600 ? 4 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return InkWell(
                  onTap: action.onTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: action.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(action.icon, color: action.color),
                          ),
                          Text(
                            action.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _UpcomingAppointments extends StatelessWidget {
  const _UpcomingAppointments({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<AppointmentRepository>();
    return Column(
      children: [
        SectionHeader(
          title: 'Upcoming appointments',
          actionLabel: 'View all',
          onAction: () => context.go(AppRoutes.patientAppointments),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Appointment>>(
          stream: repository.watchPatientAppointments(patientId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }
            if (snapshot.hasError) {
              return ErrorView(message: mapFirebaseError(snapshot.error!).message);
            }
            final upcoming = (snapshot.data ?? const <Appointment>[])
                .where((appointment) => appointment.isUpcoming)
                .take(3)
                .toList();
            if (upcoming.isEmpty) {
              return EmptyView(
                title: 'No upcoming visits',
                message: 'Book a consultation when you need care.',
                icon: Icons.event_available_outlined,
                action: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.patientSearch),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Find a doctor'),
                ),
              );
            }
            return Column(
              children: [
                for (final appointment in upcoming)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppointmentTile(appointment: appointment),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TopDoctors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = context.read<DoctorRepository>();
    return Column(
      children: [
        SectionHeader(
          title: 'Recommended doctors',
          actionLabel: 'See all',
          onAction: () => context.go(AppRoutes.patientSearch),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<DoctorProfile>>(
          stream: repository.watchDoctors(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }
            if (snapshot.hasError) {
              return ErrorView(message: mapFirebaseError(snapshot.error!).message);
            }
            final doctors = (snapshot.data ?? const <DoctorProfile>[])
                .take(3)
                .toList();
            if (doctors.isEmpty) {
              return const EmptyView(
                title: 'No doctors available yet',
                message: 'Doctors appear here once they publish a profile.',
                icon: Icons.medical_information_outlined,
              );
            }
            return Column(
              children: [
                for (final doctor in doctors)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DoctorCard(
                      doctor: doctor,
                      onBook: () => context.go(AppRoutes.booking(doctor.id)),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NearbyClinics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = context.read<DoctorRepository>();
    return Column(
      children: [
        const SectionHeader(
          title: 'Nearby clinics',
          subtitle: 'Practices published by available doctors',
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<DoctorProfile>>(
          stream: repository.watchDoctors(),
          builder: (context, snapshot) {
            final clinics = <String>{
              for (final doctor in snapshot.data ?? const <DoctorProfile>[])
                if (doctor.clinicName != null && doctor.clinicName!.isNotEmpty)
                  '${doctor.clinicName} • ${doctor.city}',
            }.take(4).toList();
            if (clinics.isEmpty) {
              return const EmptyView(
                title: 'No clinics listed',
                icon: Icons.local_hospital_outlined,
              );
            }
            return SizedBox(
              height: 116,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: clinics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 230,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.local_hospital_outlined,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                clinics[index],
                                maxLines: 3,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MedicinesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repository = context.read<MedicineRepository>();
    return Column(
      children: [
        SectionHeader(
          title: 'Medicines',
          actionLabel: 'Shop all',
          onAction: () => context.go(AppRoutes.patientMedicines),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Medicine>>(
          stream: repository.watchMedicines(),
          builder: (context, snapshot) {
            final medicines = (snapshot.data ?? const <Medicine>[]).take(4).toList();
            if (medicines.isEmpty) {
              return const EmptyView(
                title: 'No medicines listed',
                icon: Icons.medication_outlined,
              );
            }
            return SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: medicines.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  return SizedBox(
                    width: 190,
                    child: Card(
                      child: InkWell(
                        onTap: () => context.go(
                          AppRoutes.medicineDetails(medicine.id),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.medication_liquid_outlined,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 8),
                              Text(
                                medicine.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                AppFormatters.currency(medicine.price),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HealthTip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_outlined,
              color: scheme.onSecondaryContainer),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Health tip: Aim for 30 minutes of movement and seven hours of sleep each day.',
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
