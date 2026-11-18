import 'package:aarogivya/app/dependencies.dart';
import 'package:aarogivya/app/router.dart';
import 'package:aarogivya/core/presentation/theme_provider.dart';
import 'package:aarogivya/core/theme/app_theme.dart';
import 'package:aarogivya/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:aarogivya/features/auth/domain/repositories/auth_repository.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:aarogivya/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:aarogivya/features/notifications/domain/repositories/notification_repository.dart';
import 'package:aarogivya/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:aarogivya/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:aarogivya/features/records/domain/repositories/health_records_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AarogivyaApp extends StatefulWidget {
  const AarogivyaApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<AarogivyaApp> createState() => _AarogivyaAppState();
}

class _AarogivyaAppState extends State<AarogivyaApp> {
  late final GoRouter _router = createAppRouter(
    authProvider: widget.dependencies.authProvider,
    onboardingProvider: widget.dependencies.onboardingProvider,
  );

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: dependencies.authRepository),
        Provider<OnboardingRepository>.value(
          value: dependencies.onboardingRepository,
        ),
        Provider<AppointmentRepository>.value(
          value: dependencies.appointmentRepository,
        ),
        Provider<DoctorRepository>.value(value: dependencies.doctorRepository),
        Provider<MedicineRepository>.value(
          value: dependencies.medicineRepository,
        ),
        Provider<NotificationRepository>.value(
          value: dependencies.notificationRepository,
        ),
        Provider<HealthRecordsRepository>.value(
          value: dependencies.healthRecordsRepository,
        ),
        ChangeNotifierProvider<AuthProvider>.value(
          value: dependencies.authProvider,
        ),
        ChangeNotifierProvider<OnboardingProvider>.value(
          value: dependencies.onboardingProvider,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(
          value: dependencies.themeProvider,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Aarogivya',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
