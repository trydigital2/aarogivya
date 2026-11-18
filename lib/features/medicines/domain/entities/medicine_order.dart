import 'package:aarogivya/core/utils/firestore_values.dart';
import 'package:aarogivya/features/medicines/domain/entities/cart_item.dart';

enum OrderStatus { placed, verified, packed, shipped, delivered, rejected }

class MedicineOrder {
  const MedicineOrder({
    required this.id,
    required this.patientId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.prescriptionRecordId,
  });

  final String id;
  final String patientId;
  final List<CartItem> items;
  final num total;
  final OrderStatus status;
  final DateTime createdAt;
  final String? prescriptionRecordId;

  factory MedicineOrder.fromMap(String id, Map<String, dynamic> map) {
    return MedicineOrder(
      id: id,
      patientId: FirestoreValues.string(map['patientId']),
      items: (map['items'] as List? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (raw) => CartItem(
              medicineId: FirestoreValues.string(raw['medicineId']),
              name: FirestoreValues.string(raw['name'], 'Medicine'),
              price: FirestoreValues.number(raw['price']),
              quantity: FirestoreValues.number(raw['quantity'], 1).toInt(),
              imageUrl: raw['imageUrl'] as String?,
              requiresPrescription:
                  FirestoreValues.boolean(raw['requiresPrescription']),
            ),
          )
          .toList(growable: false),
      total: FirestoreValues.number(map['total']),
      status: OrderStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => OrderStatus.placed,
      ),
      createdAt: FirestoreValues.date(map['createdAt']),
      prescriptionRecordId: map['prescriptionRecordId'] as String?,
    );
  }
}
