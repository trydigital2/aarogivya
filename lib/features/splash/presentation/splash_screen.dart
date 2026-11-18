import 'dart:async';

import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/widgets/app_logo.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();
  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );
  Timer? _timer;
  bool _navigated = false;
  bool _minimumDelayComplete = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), () {
      _minimumDelayComplete = true;
      _navigateIfReady();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigateIfReady();
  }

  void _navigateIfReady() {
    if (_navigated || !_minimumDelayComplete || !mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.status == AuthStatus.unknown) return;

    final onboarding = context.read<OnboardingProvider>();
    _navigated = true;

    if (!onboarding.isCompleted) {
      context.go(AppRoutes.onboarding);
    } else if (auth.status == AuthStatus.authenticated) {
      context.go(auth.isPatient ? AppRoutes.patientHome : AppRoutes.doctorHome);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: const AppLogo(size: 82, showText: false),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Aarogivya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your Health, Our Priority.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 44),
                const SizedBox.square(
                  dimension: 28,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
