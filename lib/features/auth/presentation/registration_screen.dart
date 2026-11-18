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

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  UserRole _role = UserRole.patient;
  bool _obscurePassword = true;
  bool _acceptedTerms = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms to continue.')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      role: _role,
    );
    if (success && mounted && auth.user != null) {
      context.go(auth.isPatient ? AppRoutes.patientHome : AppRoutes.doctorHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Join Aarogivya to manage care with confidence.',
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account?'),
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Sign in'),
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
              label: 'Full name',
              controller: _nameController,
              hint: 'Your full name',
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.required(value, 'Full name'),
            ),
            const SizedBox(height: 16),
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
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 16),
            AppTextField(
              label: 'Confirm password',
              controller: _confirmController,
              hint: 'Repeat your password',
              prefixIcon: Icons.lock_reset_outlined,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: (value) => Validators.confirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _acceptedTerms,
              onChanged: (value) =>
                  setState(() => _acceptedTerms = value ?? false),
              title: const Text(
                'I agree to the Terms of Service and Privacy Policy',
                style: TextStyle(fontSize: 13),
              ),
            ),
            AppButton(
              label: 'Create account',
              icon: Icons.person_add_alt_1_outlined,
              isLoading: auth.isBusy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
