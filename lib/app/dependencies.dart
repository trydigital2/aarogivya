import 'package:aarogivya/core/presentation/theme_provider.dart';
import 'package:aarogivya/data/local/local_appointment_repository.dart';
import 'package:aarogivya/data/local/local_auth_repository.dart';
import 'package:aarogivya/data/local/local_doctor_repository.dart';
import 'package:aarogivya/data/local/local_health_records_repository.dart';
import 'package:aarogivya/data/local/local_medicine_repository.dart';
import 'package:aarogivya/data/local/local_notification_repository.dart';
import 'package:aarogivya/data/local/local_push_notification_service.dart';
import 'package:aarogivya/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:aarogivya/features/auth/domain/repositories/auth_repository.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:aarogivya/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:aarogivya/features/notifications/domain/repositories/notification_repository.dart';
import 'package:aarogivya/features/onboarding/data/repositories/shared_preferences_onboarding_repository.dart';
import 'package:aarogivya/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:aarogivya/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:aarogivya/features/records/domain/repositories/health_records_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDependencies {
  AppDependencies._({
    required this.authRepository,
    required this.onboardingRepository,
    required this.appointmentRepository,
    required this.doctorRepository,
    required this.medicineRepository,
    required this.notificationRepository,
    required this.healthRecordsRepository,
    required this.authProvider,
    required this.onboardingProvider,
    required this.themeProvider,
    required this.pushNotificationService,
  });

  final AuthRepository authRepository;
  final OnboardingRepository onboardingRepository;
  final AppointmentRepository appointmentRepository;
  final DoctorRepository doctorRepository;
  final MedicineRepository medicineRepository;
  final NotificationRepository notificationRepository;
  final HealthRecordsRepository healthRecordsRepository;
  final AuthProvider authProvider;
  final OnboardingProvider onboardingProvider;
  final ThemeProvider themeProvider;
  final PushNotificationService pushNotificationService;

  static Future<AppDependencies> create() async {
    final preferences = await SharedPreferences.getInstance();

    final authRepository = LocalAuthRepository(preferences);
    final onboardingRepository =
        SharedPreferencesOnboardingRepository(preferences);
    final doctorRepository = LocalDoctorRepository();
    final appointmentRepository = LocalAppointmentRepository(doctorRepository);
    final medicineRepository = LocalMedicineRepository();
    final notificationRepository = LocalNotificationRepository();
    final healthRecordsRepository = LocalHealthRecordsRepository();

    final pushNotificationService = PushNotificationService();
    final authProvider = AuthProvider(
      authRepository,
      onBeforeSignOut: pushNotificationService.unregisterToken,
    );
    final onboardingProvider = OnboardingProvider(
      onboardingRepository,
      isCompleted: await onboardingRepository.isCompleted(),
    );
    final themeProvider = ThemeProvider(preferences);

    authProvider.startListening();
    authProvider.addListener(() {
      final user = authProvider.user;
      if (user != null) {
        pushNotificationService.syncToken(user.uid);
      }
    });
    await pushNotificationService.initialize();

    return AppDependencies._(
      authRepository: authRepository,
      onboardingRepository: onboardingRepository,
      appointmentRepository: appointmentRepository,
      doctorRepository: doctorRepository,
      medicineRepository: medicineRepository,
      notificationRepository: notificationRepository,
      healthRecordsRepository: healthRecordsRepository,
      authProvider: authProvider,
      onboardingProvider: onboardingProvider,
      themeProvider: themeProvider,
      pushNotificationService: pushNotificationService,
    );
  }
}
