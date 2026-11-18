import 'package:flutter/material.dart';

enum UserRole {
  patient('patient', 'Patient', Icons.health_and_safety_outlined),
  doctor('doctor', 'Doctor', Icons.medical_services_outlined);

  const UserRole(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static UserRole fromValue(String? value) =>
      value == 'doctor' ? UserRole.doctor : UserRole.patient;
}
