import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/utils/validators.dart';
import 'package:aarogivya/core/widgets/app_button.dart';
import 'package:aarogivya/core/widgets/app_text_field.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/core/widgets/profile_avatar.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/doctor/domain/entities/doctor_profile.dart';
import 'package:aarogivya/features/doctor/domain/repositories/doctor_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DoctorProfileEditScreen extends StatefulWidget {
  const DoctorProfileEditScreen({super.key});

  @override
  State<DoctorProfileEditScreen> createState() =>
      _DoctorProfileEditScreenState();
}

class _DoctorProfileEditScreenState extends State<DoctorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _cityController = TextEditingController();
  final _clinicController = TextEditingController();
  final _aboutController = TextEditingController();
  final _languagesController = TextEditingController();
  bool _acceptingPatients = false;
  String? _photoUrl;
  bool _saving = false;
  bool _uploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _qualificationsController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _cityController.dispose();
    _clinicController.dispose();
    _aboutController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  void _populate(DoctorProfile profile) {
    if (_nameController.text.isNotEmpty) return;
    _nameController.text = profile.fullName;
    _specialtyController.text = profile.specialization;
    _qualificationsController.text = profile.qualifications.join('\n');
    _experienceController.text = '${profile.experienceYears}';
    _feeController.text = '${profile.consultationFee}';
    _cityController.text = profile.city;
    _clinicController.text = profile.clinicName ?? '';
    _aboutController.text = profile.about ?? '';
    _languagesController.text = profile.languages.join(', ');
    _acceptingPatients = profile.isAcceptingPatients;
    _photoUrl = profile.photoUrl;
  }

  Future<void> _pickImage(String doctorId) async {
    final repository = context.read<DoctorRepository>();
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _uploadingImage = true);
    try {
      final url = await repository.uploadProfileImage(doctorId, image.path);
      if (!mounted) return;
      setState(() => _photoUrl = url);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _save(String doctorId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final profile = DoctorProfile(
        id: doctorId,
        userId: doctorId,
        fullName: _nameController.text.trim(),
        specialization: _specialtyController.text.trim(),
        qualifications: _qualificationsController.text
            .split(RegExp(r'[\n,]'))
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
        experienceYears: int.tryParse(_experienceController.text.trim()) ?? 0,
        consultationFee: num.tryParse(_feeController.text.trim()) ?? 0,
        city: _cityController.text.trim(),
        clinicName: _clinicController.text.trim().isEmpty
            ? null
            : _clinicController.text.trim(),
        about: _aboutController.text.trim().isEmpty
            ? null
            : _aboutController.text.trim(),
        languages: _languagesController.text
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(),
        isAcceptingPatients: _acceptingPatients,
        photoUrl: _photoUrl,
      );
      await context.read<DoctorRepository>().saveProfile(profile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mapFirebaseError(error).message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final repository = context.read<DoctorRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Professional profile')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: AppButton(
            label: 'Save profile',
            icon: Icons.save_outlined,
            isLoading: _saving,
            onPressed: () => _save(user.uid),
          ),
        ),
      ),
      body: StreamBuilder<DoctorProfile?>(
        stream: repository.watchDoctor(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const LoadingView();
          }
          if (snapshot.hasData) _populate(snapshot.data!);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    children: [
                      ProfileAvatar(
                        imageUrl: _photoUrl,
                        initials: _nameController.text.isEmpty
                            ? 'D'
                            : _nameController.text[0],
                        radius: 54,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: IconButton(
                            onPressed: _uploadingImage
                                ? null
                                : () => _pickImage(user.uid),
                            icon: _uploadingImage
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.camera_alt_outlined,
                                    size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: 'Full name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) => Validators.required(value, 'Name'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Specialization',
                    controller: _specialtyController,
                    prefixIcon: Icons.medical_services_outlined,
                    validator: (value) =>
                        Validators.required(value, 'Specialization'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Qualifications (one per line)',
                    controller: _qualificationsController,
                    prefixIcon: Icons.school_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Experience (years)',
                          controller: _experienceController,
                          prefixIcon: Icons.work_outline_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.required(
                            value,
                            'Experience',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Consultation fee',
                          controller: _feeController,
                          prefixIcon: Icons.currency_exchange_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              Validators.positiveNumber(value, 'Fee'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'City',
                    controller: _cityController,
                    prefixIcon: Icons.location_city_outlined,
                    validator: (value) => Validators.required(value, 'City'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Clinic name',
                    controller: _clinicController,
                    prefixIcon: Icons.local_hospital_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Languages (comma separated)',
                    controller: _languagesController,
                    prefixIcon: Icons.translate_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'About',
                    controller: _aboutController,
                    prefixIcon: Icons.info_outline_rounded,
                    maxLines: 4,
                  ),
                  SwitchListTile(
                    title: const Text('Accepting new patients'),
                    subtitle: const Text(
                      'Publish this profile in patient search',
                    ),
                    value: _acceptingPatients,
                    onChanged: (value) =>
                        setState(() => _acceptingPatients = value),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
