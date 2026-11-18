import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/medicines/domain/entities/medicine_order.dart';
import 'package:aarogivya/features/medicines/domain/repositories/medicine_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MedicineOrdersScreen extends StatelessWidget {
  const MedicineOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final repository = context.read<MedicineRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Order history')),
      body: StreamBuilder<List<MedicineOrder>>(
        stream: repository.watchOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(message: mapFirebaseError(snapshot.error!).message);
          }
          final orders = snapshot.data ?? const <MedicineOrder>[];
          if (orders.isEmpty) {
            return const EmptyView(
              title: 'No orders yet',
              message: 'Your medicine orders and delivery status appear here.',
              icon: Icons.receipt_long_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          _StatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppFormatters.dateTime(order.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      for (final item in order.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text('${item.name} × ${item.quantity}')),
                              Text(AppFormatters.currency(item.total)),
                            ],
                          ),
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(
                            AppFormatters.currency(order.total),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final labels = <OrderStatus, String>{
      OrderStatus.placed: 'Placed',
      OrderStatus.verified: 'Verified',
      OrderStatus.packed: 'Packed',
      OrderStatus.shipped: 'Shipped',
      OrderStatus.delivered: 'Delivered',
      OrderStatus.rejected: 'Rejected',
    };
    final colors = <OrderStatus, Color>{
      OrderStatus.placed: Colors.blue,
      OrderStatus.verified: Colors.teal,
      OrderStatus.packed: Colors.orange,
      OrderStatus.shipped: Colors.purple,
      OrderStatus.delivered: Colors.green,
      OrderStatus.rejected: Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[status] ?? status.name,
        style: TextStyle(
          color: colors[status] ?? Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
