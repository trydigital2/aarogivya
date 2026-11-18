import 'package:aarogivya/app/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class BottomNavHelper {
  static int indexFor(String path, List<String> destinations) {
    var bestIndex = 0;
    var bestLength = 0;
    for (var index = 0; index < destinations.length; index++) {
      final destination = destinations[index];
      if ((path == destination || path.startsWith('$destination/')) &&
          destination.length > bestLength) {
        bestIndex = index;
        bestLength = destination.length;
      }
    }
    return bestIndex;
  }
}

class PatientShell extends StatelessWidget {
  const PatientShell({
    super.key,
    required this.navigationShell,
    required this.currentPath,
  });

  final StatefulNavigationShell navigationShell;
  final String currentPath;

  static const _destinations = <String>[
    AppRoutes.patientHome,
    AppRoutes.patientSearch,
    AppRoutes.patientAppointments,
    AppRoutes.patientMedicines,
    AppRoutes.patientProfile,
  ];

  @override
  Widget build(BuildContext context) {
    final selected = BottomNavHelper.indexFor(currentPath, _destinations);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (index) => context.go(_destinations[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Doctors',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Visits',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication_rounded),
            label: 'Medicines',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DoctorShell extends StatelessWidget {
  const DoctorShell({
    super.key,
    required this.navigationShell,
    required this.currentPath,
  });

  final StatefulNavigationShell navigationShell;
  final String currentPath;

  static const _destinations = <String>[
    AppRoutes.doctorHome,
    AppRoutes.doctorAppointments,
    AppRoutes.doctorPatients,
    AppRoutes.doctorProfileEdit,
  ];

  @override
  Widget build(BuildContext context) {
    final selected = BottomNavHelper.indexFor(currentPath, _destinations);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: (index) => context.go(_destinations[index]),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
