import 'package:aarogivya/app/app_routes.dart';
import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/medicines/domain/entities/medicine.dart';
import 'package:aarogivya/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final _searchController = TextEditingController();
  String _category = 'All';
  static const _categories = <String>[
    'All',
    'Pain Relief',
    'Vitamins',
    'Cardiac',
    'Diabetes',
    'Skin Care',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<MedicineRepository>();
    final user = context.watch<AuthProvider>().user!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicines'),
        actions: [
          StreamBuilder(
            stream: repository.watchCart(user.uid),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: IconButton(
                  onPressed: () => context.go(AppRoutes.patientCart),
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () => context.go(AppRoutes.patientOrders),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search medicines',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                return FilterChip(
                  label: Text(category),
                  selected: category == _category,
                  onSelected: (_) => setState(() => _category = category),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: StreamBuilder<List<Medicine>>(
              stream: repository.watchMedicines(
                category: _category,
                search: _searchController.text,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingView(message: 'Loading medicines...');
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: mapFirebaseError(snapshot.error!).message,
                  );
                }
                final medicines = snapshot.data ?? const <Medicine>[];
                if (medicines.isEmpty) {
                  return const EmptyView(
                    title: 'No medicines found',
                    icon: Icons.medication_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: medicines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.medication_liquid_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(medicine.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(medicine.category),
                            if (medicine.requiresPrescription)
                              Text(
                                'Prescription required',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          AppFormatters.currency(medicine.price),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        onTap: () => context.go(
                          AppRoutes.medicineDetails(medicine.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
