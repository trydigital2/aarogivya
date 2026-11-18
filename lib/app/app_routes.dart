abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String phoneLogin = '/phone-login';

  static const String patientHome = '/patient';
  static const String patientSearch = '/patient/search';
  static const String patientAppointments = '/patient/appointments';
  static const String patientMedicines = '/patient/medicines';
  static const String patientCart = '/patient/cart';
  static const String patientOrders = '/patient/orders';
  static const String patientRecords = '/patient/records';
  static const String patientNotifications = '/patient/notifications';
  static const String patientProfile = '/patient/profile';
  static const String patientSettings = '/patient/settings';

  static String doctorProfile(String doctorId) => '$patientSearch/$doctorId';
  static String booking(String doctorId) => '${doctorProfile(doctorId)}/book';
  static String medicineDetails(String medicineId) =>
      '$patientMedicines/$medicineId';

  static const String doctorHome = '/doctor';
  static const String doctorAppointments = '/doctor/appointments';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorProfileEdit = '/doctor/profile/edit';
  static const String doctorSlots = '/doctor/slots';
  static const String doctorSettings = '/doctor/settings';
}
