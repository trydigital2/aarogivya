import 'package:aarogivya/app/app.dart';
import 'package:aarogivya/app/dependencies.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(AarogivyaApp(dependencies: dependencies));
}
