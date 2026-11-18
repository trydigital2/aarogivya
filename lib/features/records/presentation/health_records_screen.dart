import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/utils/validators.dart';
import 'package:aarogivya/core/widgets/app_button.dart';
import 'package:aarogivya/core/widgets/app_text_field.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/patient/domain/entities/patient_profile.dart';
import 'package:aarogivya/features/records/domain/entities/medical_record.dart';
import 'package:aarogivya/features/records/domain/repositories/health_records_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  int _tab = 0;
  bool _isUploading = false;

  Future<void> _uploadDocument(String patientId) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (files.isEmpty || !mounted) return;
    final file = files.single;
    final path = file.path;
    if (path == null) return;

    final titleController = TextEditingController(text: file.name);
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Document title'),
        content: AppTextField(
          label: 'Title',
          controller: titleController,
          validator: (value) => Validators.required(value, 'Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(titleController.text.trim()),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty || !mounted) return;

    setState(() => _isUploading = true);
    final repository = context.read<HealthRecordsRepository>();
    try {
      await repository.uploadRecord(
            patientId: patientId,
            title: title,
            type: MedicalRecordType.report,
            filePath: path,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded securely.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFirebaseError(error).message)),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _addMeasurement(String patientId) async {
    final titleController = TextEditingController(text: 'Blood pressure');
    final valueController = TextEditingController();
    final unitController = TextEditingController(text: 'mmHg');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add measurement'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Measurement',
                controller: titleController,
                validator: (value) => Validators.required(value, 'Measurement'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Value',
                controller: valueController,
                keyboardType: TextInputType.number,
                validator: (value) => Validators.positiveNumber(value, 'Value'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Unit',
                controller: unitController,
                validator: (value) => Validators.required(value, 'Unit'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true || !mounted) return;

    final repository = context.read<HealthRecordsRepository>();
    try {
      await repository.addMeasurement(
            patientId: patientId,
            title: titleController.text.trim(),
            value: num.parse(valueController.text.trim()),
            unit: unitController.text.trim(),
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFirebaseError(error).message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final repository = context.read<HealthRecordsRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Health records')),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _isUploading ? null : () => _uploadDocument(user.uid),
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(_isUploading ? 'Uploading...' : 'Add document'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Documents')),
                ButtonSegment(value: 1, label: Text('Medical info')),
              ],
              selected: <int>{_tab},
              onSelectionChanged: (selection) =>
                  setState(() => _tab = selection.first),
            ),
          ),
          Expanded(
            child: _tab == 0
                ? StreamBuilder<List<MedicalRecord>>(
                    stream: repository.watchRecords(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingView();
                      }
                      if (snapshot.hasError) {
                        return ErrorView(
                          message: mapFirebaseError(snapshot.error!).message,
                        );
                      }
                      final records = snapshot.data ?? const <MedicalRecord>[];
                      if (records.isEmpty) {
                        return const EmptyView(
                          title: 'No records yet',
                          message: 'Upload reports and prescriptions securely.',
                          icon: Icons.folder_shared_outlined,
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                        itemCount: records.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Icon(_iconFor(record.type)),
                              ),
                              title: Text(record.title),
                              subtitle: Text(
                                '${AppFormatters.date(record.createdAt)}'
                                '${record.value != null ? ' • ${record.value} ${record.unit ?? ''}' : ''}',
                              ),
                              trailing: record.verified
                                  ? const Icon(Icons.verified_rounded,
                                      color: Colors.green)
                                  : null,
                              onTap: record.fileUrl == null
                                  ? null
                                  : () => _showRecordDetails(record),
                            ),
                          );
                        },
                      );
                    },
                  )
                : _MedicalInfoTab(
                    userId: user.uid,
                    onAddMeasurement: () => _addMeasurement(user.uid),
                  ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (record.notes != null) Text(record.notes!),
              const SizedBox(height: 12),
              const Text(
                'Documents are stored in private Firebase Storage and can only be opened by this account.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(MedicalRecordType type) {
    switch (type) {
      case MedicalRecordType.report:
        return Icons.description_outlined;
      case MedicalRecordType.prescription:
        return Icons.medication_outlined;
      case MedicalRecordType.measurement:
        return Icons.monitor_heart_outlined;
      case MedicalRecordType.note:
        return Icons.note_alt_outlined;
    }
  }
}

class _MedicalInfoTab extends StatefulWidget {
  const _MedicalInfoTab({
    required this.userId,
    required this.onAddMeasurement,
  });

  final String userId;
  final VoidCallback onAddMeasurement;

  @override
  State<_MedicalInfoTab> createState() => _MedicalInfoTabState();
}

class _MedicalInfoTabState extends State<_MedicalInfoTab> {
  final _allergiesController = TextEditingController();
  final _historyController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _allergiesController.dispose();
    _historyController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  void _initializeFields(PatientProfile? profile) {
    if (_initialized || profile == null) return;
    _allergiesController.text = profile.allergies.join(', ');
    _historyController.text = profile.medicalHistory;
    _bloodGroupController.text = profile.bloodGroup;
    _initialized = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<HealthRecordsRepository>().updatePatientProfile(
            PatientProfile(
              userId: widget.userId,
              allergies: _allergiesController.text
                  .split(',')
                  .map((item) => item.trim())
                  .where((item) => item.isNotEmpty)
                  .toList(),
              medicalHistory: _historyController.text.trim(),
              bloodGroup: _bloodGroupController.text.trim(),
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical information updated.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFirebaseError(error).message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<HealthRecordsRepository>();
    return StreamBuilder<PatientProfile?>(
      stream: repository.watchPatientProfile(widget.userId),
      builder: (context, snapshot) {
        _initializeFields(snapshot.data);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: widget.onAddMeasurement,
                  icon: const Icon(Icons.monitor_heart_outlined),
                  label: const Text('Add measurement'),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Allergies (comma separated)',
                controller: _allergiesController,
                prefixIcon: Icons.coronavirus_outlined,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Blood group',
                controller: _bloodGroupController,
                prefixIcon: Icons.bloodtype_outlined,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Medical history',
                controller: _historyController,
                prefixIcon: Icons.history_edu_outlined,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Save medical information',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        );
      },
    );
  }
}
