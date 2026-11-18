import 'package:aarogivya/app/app_routes.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.patient;
  bool _obscurePassword = true;
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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted && auth.user != null) {
      context.go(
        auth.isPatient ? AppRoutes.patientHome : AppRoutes.doctorHome,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue to your health dashboard.',
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account?"),
          TextButton(
            onPressed: () => context.go(AppRoutes.register),
            child: const Text('Create account'),
          ),
        ],
      ),
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
              label: 'Email address',
              controller: _emailController,
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Password',
              controller: _passwordController,
              hint: 'At least 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: Validators.password,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.forgotPassword),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: 4),
            AppButton(
              label: 'Sign in',
              icon: Icons.arrow_forward_rounded,
              isLoading: auth.isBusy,
              onPressed: _submit,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Divider(color: Theme.of(context).colorScheme.outline),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or'),
                ),
                Expanded(
                  child: Divider(color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: auth.isBusy
                  ? null
                  : () => auth.signInWithGoogle(_role),
              icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
              label: const Text('Continue with Google'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: auth.isBusy
                  ? null
                  : () => context.go(AppRoutes.phoneLogin),
              icon: const Icon(Icons.phone_android_outlined),
              label: const Text('Continue with phone'),
            ),
          ],
        ),
      ),
    );
  }
}
