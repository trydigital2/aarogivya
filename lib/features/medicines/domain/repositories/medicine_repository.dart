import 'package:aarogivya/features/medicines/domain/entities/cart_item.dart';
import 'package:aarogivya/features/medicines/domain/entities/medicine.dart';
import 'package:aarogivya/features/medicines/domain/entities/medicine_order.dart';

abstract interface class MedicineRepository {
  Stream<List<Medicine>> watchMedicines({String? category, String? search});

  Future<Medicine?> getMedicine(String medicineId);

  Stream<List<CartItem>> watchCart(String patientId);

  Future<void> addToCart({required String patientId, required Medicine medicine});

  Future<void> updateQuantity({
    required String patientId,
    required String medicineId,
    required int quantity,
  });

  Future<void> removeFromCart({
    required String patientId,
    required String medicineId,
  });

  Future<void> placeOrder({
    required String patientId,
    String? prescriptionRecordId,
  });

  Stream<List<MedicineOrder>> watchOrders(String patientId);
}
