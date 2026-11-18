import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/widgets/app_button.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/medicines/domain/entities/medicine.dart';
import 'package:aarogivya/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MedicineDetailsScreen extends StatefulWidget {
  const MedicineDetailsScreen({super.key, required this.medicineId});

  final String medicineId;

  @override
  State<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends State<MedicineDetailsScreen> {
  late final Future<Medicine?> _medicineFuture;
  Medicine? _medicine;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _medicineFuture = context
        .read<MedicineRepository>()
        .getMedicine(widget.medicineId)
        .then((medicine) {
      _medicine = medicine;
      return medicine;
    });
  }

  Future<void> _addToCart() async {
    final medicine = _medicine;
    if (medicine == null || medicine.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This medicine is currently unavailable.')),
      );
      return;
    }
    setState(() => _isAdding = true);
    try {
      await context.read<MedicineRepository>().addToCart(
            patientId: context.read<AuthProvider>().user!.uid,
            medicine: medicine,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine details')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cart',
                  isOutlined: true,
                  onPressed: () => context.go(AppRoutes.patientCart),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Add to cart',
                  icon: Icons.add_shopping_cart_outlined,
                  isLoading: _isAdding,
                  onPressed: _addToCart,
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<Medicine?>(
        future: _medicineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(message: snapshot.error.toString());
          }
          final medicine = snapshot.data;
          if (medicine == null) {
            return const Center(child: Text('Medicine not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.medication_liquid_outlined,
                    size: 76,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  medicine.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${medicine.category}${medicine.manufacturer == null ? '' : ' • ${medicine.manufacturer}'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppFormatters.currency(medicine.price),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (medicine.requiresPrescription)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'A verified prescription is required to order this medicine.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(medicine.description.isEmpty
                    ? 'No description available.'
                    : medicine.description),
                if (medicine.dosage != null) ...[
                  const SizedBox(height: 16),
                  Text('Dosage: ${medicine.dosage}'),
                ],
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}
