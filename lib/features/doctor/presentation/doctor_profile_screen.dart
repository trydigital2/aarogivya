import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/app_button.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/core/widgets/profile_avatar.dart';
import 'package:aarogivya/features/doctor/domain/entities/doctor_profile.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DoctorRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor profile')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: AppButton(
            label: 'Book appointment',
            icon: Icons.calendar_month_rounded,
            onPressed: () => context.go(AppRoutes.booking(doctorId)),
          ),
        ),
      ),
      body: StreamBuilder<DoctorProfile?>(
        stream: repository.watchDoctor(doctorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(message: mapFirebaseError(snapshot.error!).message);
          }
          final doctor = snapshot.data;
          if (doctor == null) {
            return const Center(child: Text('This profile is unavailable.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        ProfileAvatar(
                          imageUrl: doctor.photoUrl,
                          initials: AppFormatters.initials(doctor.fullName),
                          radius: 52,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          doctor.fullName,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialization,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          children: [
                            _InfoPill(
                              icon: Icons.work_outline_rounded,
                              label: '${doctor.experienceYears} yrs exp.',
                            ),
                            _InfoPill(
                              icon: Icons.star_outline_rounded,
                              label: '${doctor.rating.toStringAsFixed(1)} rating',
                            ),
                            _InfoPill(
                              icon: Icons.location_on_outlined,
                              label: doctor.city.isEmpty ? 'Remote' : doctor.city,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoSection(
                  title: 'About',
                  child: Text(
                    doctor.about ?? 'No biography has been added yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoSection(
                  title: 'Qualifications',
                  child: doctor.qualifications.isEmpty
                      ? const Text('No qualifications listed')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final qualification in doctor.qualifications)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(qualification)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InfoSection(
                  title: 'Consultation',
                  child: Row(
                    children: [
                      Icon(Icons.currency_exchange_rounded,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${AppFormatters.currency(doctor.consultationFee)} per visit',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
