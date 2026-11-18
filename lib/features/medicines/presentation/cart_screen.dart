import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/app_button.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/medicines/domain/entities/cart_item.dart';
import 'package:aarogivya/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:aarogivya/features/records/domain/entities/medical_record.dart';
import 'package:aarogivya/features/records/domain/repositories/health_records_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _selectedPrescriptionId;
  bool _isPlacingOrder = false;
  bool _isUploading = false;

  Future<void> _uploadPrescription(String patientId) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final path = files.isEmpty ? null : files.single.path;
    if (path == null || !mounted) return;

    setState(() => _isUploading = true);
    try {
      final id = await context.read<HealthRecordsRepository>().uploadRecord(
            patientId: patientId,
            title: 'Prescription ${DateTime.now().year}',
            type: MedicalRecordType.prescription,
            filePath: path,
            notes: 'Uploaded for medicine order verification',
          );
      if (!mounted) return;
      setState(() => _selectedPrescriptionId = id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Prescription uploaded. A doctor must verify it before the order can be placed.',
          ),
        ),
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

  Future<void> _placeOrder(String patientId, bool needsPrescription) async {
    if (needsPrescription && _selectedPrescriptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a verified prescription to continue.'),
        ),
      );
      return;
    }
    setState(() => _isPlacingOrder = true);
    try {
      await context.read<MedicineRepository>().placeOrder(
            patientId: patientId,
            prescriptionRecordId: _selectedPrescriptionId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully.')),
      );
      context.go(AppRoutes.patientOrders);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapFirebaseError(error).message)),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final medicineRepository = context.read<MedicineRepository>();
    final recordsRepository = context.read<HealthRecordsRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: StreamBuilder<List<CartItem>>(
        stream: medicineRepository.watchCart(user.uid),
        builder: (context, cartSnapshot) {
          final cart = cartSnapshot.data ?? const <CartItem>[];
          final total = cart.fold<num>(0, (sum, item) => sum + item.total);
          final needsPrescription =
              cart.any((item) => item.requiresPrescription);

          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cart.isEmpty) {
            return const EmptyView(
              title: 'Your cart is empty',
              message: 'Browse medicines and add what you need.',
              icon: Icons.shopping_cart_outlined,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: cart.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '${AppFormatters.currency(item.price)} each'
                          '${item.requiresPrescription ? ' • Prescription required' : ''}',
                        ),
                        trailing: SizedBox(
                          width: 116,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => medicineRepository.updateQuantity(
                                  patientId: user.uid,
                                  medicineId: item.medicineId,
                                  quantity: item.quantity - 1,
                                ),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                onPressed: () => medicineRepository.updateQuantity(
                                  patientId: user.uid,
                                  medicineId: item.medicineId,
                                  quantity: item.quantity + 1,
                                ),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (needsPrescription)
                StreamBuilder<List<MedicalRecord>>(
                  stream: recordsRepository.watchRecords(user.uid),
                  builder: (context, recordsSnapshot) {
                    final prescriptions = (recordsSnapshot.data ??
                            const <MedicalRecord>[])
                        .where(
                          (record) =>
                              record.type == MedicalRecordType.prescription &&
                              record.verified,
                        )
                        .toList();
                    final selectedExists = prescriptions.any(
                      (record) => record.id == _selectedPrescriptionId,
                    );
                    if (!selectedExists) _selectedPrescriptionId = null;
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Verified prescription',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          if (prescriptions.isEmpty)
                            Text(
                              'No verified prescription yet. Upload one and ask a doctor to verify it.',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          else
                            DropdownButtonFormField<String>(
                              initialValue: _selectedPrescriptionId,
                              decoration: const InputDecoration(
                                labelText: 'Select prescription',
                              ),
                              items: [
                                for (final record in prescriptions)
                                  DropdownMenuItem(
                                    value: record.id,
                                    child: Text(record.title),
                                  ),
                              ],
                              onChanged: (value) => setState(
                                () => _selectedPrescriptionId = value,
                              ),
                            ),
                          TextButton.icon(
                            onPressed: _isUploading
                                ? null
                                : () => _uploadPrescription(user.uid),
                            icon: const Icon(Icons.upload_file_outlined),
                            label: Text(
                              _isUploading
                                  ? 'Uploading...'
                                  : 'Upload new prescription',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              Container(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          AppFormatters.currency(total),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Place order',
                      icon: Icons.shopping_bag_outlined,
                      isLoading: _isPlacingOrder,
                      onPressed: () =>
                          _placeOrder(user.uid, needsPrescription),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
