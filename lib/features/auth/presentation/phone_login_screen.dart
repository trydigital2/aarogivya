import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/error/app_failure.dart';
import 'package:aarogivya/core/utils/validators.dart';
import 'package:aarogivya/core/widgets/app_button.dart';
import 'package:aarogivya/core/widgets/app_text_field.dart';
import 'package:aarogivya/features/auth/domain/entities/user_role.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:aarogivya/features/auth/presentation/widgets/role_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  UserRole _role = UserRole.patient;
  String? _shownError;

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().addListener(_handleAuthChange);
  }

  void _handleAuthChange() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final error = auth.errorMessage;
    if (error != null && error != _shownError) {
      _shownError = error;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
    if (error == null) _shownError = null;
  }

  @override
  void dispose() {
    context.read<AuthProvider>().removeListener(_handleAuthChange);
    _phoneController.dispose();
    super.dispose();
  }

  Future<String> _promptForCode(String verificationId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verify your number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the 6-digit code sent to ${_phoneController.text.trim()}.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Verification code',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.length == 6) Navigator.of(dialogContext).pop(code);
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty) {
      throw const AuthFailure('Verification was cancelled.');
    }
    return result;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithPhone(
      phoneNumber: _phoneController.text.trim(),
      role: _role,
      smsCodeProvider: _promptForCode,
    );
    if (success && mounted && auth.user != null) {
      context.go(auth.isPatient ? AppRoutes.patientHome : AppRoutes.doctorHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthScaffold(
      title: 'Phone verification',
      subtitle: 'Sign in with a one-time code sent by SMS.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoleSelector(
              selected: _role,
              onChanged: (role) => setState(() => _role = role),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Phone number',
              controller: _phoneController,
              hint: '+911234567890',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              validator: Validators.phone,
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Send verification code',
              icon: Icons.sms_outlined,
              isLoading: auth.isBusy,
              onPressed: _submit,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
