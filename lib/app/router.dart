import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/app/shells/app_shells.dart';
import 'package:aarogivya/features/appointments/presentation/appointment_booking_screen.dart';
import 'package:aarogivya/features/appointments/presentation/my_appointments_screen.dart';
import 'package:aarogivya/features/auth/presentation/forgot_password_screen.dart';
import 'package:aarogivya/features/auth/presentation/login_screen.dart';
import 'package:aarogivya/features/auth/presentation/phone_login_screen.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/auth/presentation/registration_screen.dart';
import 'package:aarogivya/features/doctor/presentation/doctor_appointments_screen.dart';
import 'package:aarogivya/features/doctor/presentation/doctor_dashboard_screen.dart';
import 'package:aarogivya/features/doctor/presentation/doctor_patients_screen.dart';
import 'package:aarogivya/features/doctor/presentation/doctor_profile_edit_screen.dart';
import 'package:aarogivya/features/doctor/presentation/doctor_profile_screen.dart';
import 'package:aarogivya/features/doctor/presentation/doctor_search_screen.dart';
import 'package:aarogivya/features/doctor/presentation/doctor_slots_screen.dart';
import 'package:aarogivya/features/medicines/presentation/cart_screen.dart';
import 'package:aarogivya/features/medicines/presentation/medicine_details_screen.dart';
import 'package:aarogivya/features/medicines/presentation/medicine_orders_screen.dart';
import 'package:aarogivya/features/medicines/presentation/medicine_screen.dart';
import 'package:aarogivya/features/notifications/presentation/notifications_screen.dart';
import 'package:aarogivya/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aarogivya/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:aarogivya/features/patient/presentation/patient_dashboard_screen.dart';
import 'package:aarogivya/features/profile/presentation/user_profile_screen.dart';
import 'package:aarogivya/features/records/presentation/health_records_screen.dart';
import 'package:aarogivya/features/settings/presentation/settings_screen.dart';
import 'package:aarogivya/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({
  required AuthProvider authProvider,
  required OnboardingProvider onboardingProvider,
}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: Listenable.merge([authProvider, onboardingProvider]),
    redirect: (context, state) {
      final path = state.uri.path;
      final isSplash = path == AppRoutes.splash;
      final isOnboarding = path == AppRoutes.onboarding;
      final isAuthRoute = path == AppRoutes.login ||
          path == AppRoutes.register ||
          path == AppRoutes.forgotPassword ||
          path == AppRoutes.phoneLogin;

      if (authProvider.status == AuthStatus.unknown) {
        return isSplash ? null : AppRoutes.splash;
      }
      if (isSplash) return null;
      if (!onboardingProvider.isCompleted && !isOnboarding) {
        return AppRoutes.onboarding;
      }
      if (isOnboarding) {
        if (authProvider.status == AuthStatus.authenticated) {
          return authProvider.isPatient
              ? AppRoutes.patientHome
              : AppRoutes.doctorHome;
        }
        return null;
      }

      final home = authProvider.isPatient
          ? AppRoutes.patientHome
          : AppRoutes.doctorHome;

      if (authProvider.status == AuthStatus.unauthenticated) {
        return isAuthRoute ? null : AppRoutes.login;
      }
      if (isAuthRoute) return home;
      if (authProvider.isPatient && path.startsWith('/doctor')) return home;
      if (!authProvider.isPatient && path.startsWith('/patient')) return home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.phoneLogin,
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => PatientShell(
          navigationShell: navigationShell,
          currentPath: state.uri.path,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.patientHome,
                builder: (context, state) => const PatientDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (context, state) => const DoctorSearchScreen(),
                    routes: [
                      GoRoute(
                        path: ':doctorId',
                        builder: (context, state) => DoctorProfileScreen(
                          doctorId: state.pathParameters['doctorId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'book',
                            builder: (context, state) => AppointmentBookingScreen(
                              doctorId: state.pathParameters['doctorId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'appointments',
                    builder: (context, state) => const MyAppointmentsScreen(),
                  ),
                  GoRoute(
                    path: 'medicines',
                    builder: (context, state) => const MedicineScreen(),
                    routes: [
                      GoRoute(
                        path: ':medicineId',
                        builder: (context, state) => MedicineDetailsScreen(
                          medicineId: state.pathParameters['medicineId']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'cart',
                    builder: (context, state) => const CartScreen(),
                  ),
                  GoRoute(
                    path: 'orders',
                    builder: (context, state) => const MedicineOrdersScreen(),
                  ),
                  GoRoute(
                    path: 'records',
                    builder: (context, state) => const HealthRecordsScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (context, state) => const NotificationsScreen(),
                  ),
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => const UserProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => DoctorShell(
          navigationShell: navigationShell,
          currentPath: state.uri.path,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.doctorHome,
                builder: (context, state) => const DoctorDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'appointments',
                    builder: (context, state) =>
                        const DoctorAppointmentsScreen(),
                  ),
                  GoRoute(
                    path: 'patients',
                    builder: (context, state) => const DoctorPatientsScreen(),
                  ),
                  GoRoute(
                    path: 'profile/edit',
                    builder: (context, state) =>
                        const DoctorProfileEditScreen(),
                  ),
                  GoRoute(
                    path: 'slots',
                    builder: (context, state) => const DoctorSlotsScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(child: Text(state.uri.toString())),
    ),
  );
}
