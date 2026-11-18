import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/utils/validators.dart';
import 'package:aarogivya/core/widgets/app_button.dart';
import 'package:aarogivya/core/widgets/app_text_field.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;
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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context
        .read<AuthProvider>()
        .sendPasswordReset(_emailController.text.trim());
    if (success && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'We’ll send a secure reset link to your email address.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Email address',
              controller: _emailController,
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: 20),
            if (_sent)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Reset link sent. Check your inbox and spam folder.',
                ),
              ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Send reset link',
              icon: Icons.send_outlined,
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
