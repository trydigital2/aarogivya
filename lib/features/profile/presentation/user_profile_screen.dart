import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/widgets/app_button.dart';
import 'package:aarogivya/core/widgets/profile_avatar.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.go(
              user.role.name == 'doctor'
                  ? AppRoutes.doctorSettings
                  : AppRoutes.patientSettings,
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    ProfileAvatar(
                      imageUrl: user.photoUrl,
                      initials: AppFormatters.initials(user.displayName),
                      radius: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(user.email.isEmpty ? user.phoneNumber ?? '' : user.email),
                    const SizedBox(height: 12),
                    Chip(label: Text(user.role.label)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProfileLink(
              icon: Icons.calendar_month_outlined,
              title: 'My appointments',
              subtitle: 'Review upcoming and past consultations',
              onTap: () => context.go(
                user.role.name == 'doctor'
                    ? AppRoutes.doctorAppointments
                    : AppRoutes.patientAppointments,
              ),
            ),
            _ProfileLink(
              icon: Icons.folder_shared_outlined,
              title: 'Health records',
              subtitle: 'Reports, prescriptions and medical information',
              onTap: () => context.go(AppRoutes.patientRecords),
            ),
            _ProfileLink(
              icon: Icons.receipt_long_outlined,
              title: 'Medicine orders',
              subtitle: 'Track purchases and delivery status',
              onTap: () => context.go(AppRoutes.patientOrders),
            ),
            _ProfileLink(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Care updates and reminders',
              onTap: () => context.go(AppRoutes.patientNotifications),
            ),
            _ProfileLink(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Appearance and account preferences',
              onTap: () => context.go(
                user.role.name == 'doctor'
                    ? AppRoutes.doctorSettings
                    : AppRoutes.patientSettings,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Sign out',
              icon: Icons.logout_rounded,
              isOutlined: true,
              isLoading: auth.isBusy,
              onPressed: auth.signOut,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
