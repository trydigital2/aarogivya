import 'dart:async';
import 'package:aarogivya/features/medicines/domain/entities/cart_item.dart';
import 'package:aarogivya/features/medicines/domain/entities/medicine.dart';
import 'package:aarogivya/features/medicines/domain/entities/medicine_order.dart';
import 'package:aarogivya/features/medicines/domain/repositories/medicine_repository.dart';

class LocalMedicineRepository implements MedicineRepository {
  LocalMedicineRepository() {
    _initMedicines();
  }

  final _medicinesController = StreamController<List<Medicine>>.broadcast();
  final _cartController = StreamController<Map<String, List<CartItem>>>.broadcast();
  final _ordersController = StreamController<List<MedicineOrder>>.broadcast();

  final List<Medicine> _medicines = [];
  final Map<String, List<CartItem>> _carts = {};
  final List<MedicineOrder> _orders = [];

  void _initMedicines() {
    _medicines.addAll([
      const Medicine(
        id: 'med_1',
        name: 'Paracetamol 650mg',
        category: 'Pain Relief',
        description: 'Effective relief for fever, headache, body pain, and mild toothache.',
        price: 32.50,
        stock: 150,
        requiresPrescription: false,
        manufacturer: 'Cipla Health',
        dosage: '1 tablet every 6 hours after food',
      ),
      const Medicine(
        id: 'med_2',
        name: 'Amoxicillin 500mg',
        category: 'Antibiotics',
        description: 'Broad-spectrum antibiotic used to treat bacterial infections.',
        price: 118.00,
        stock: 80,
        requiresPrescription: true,
        manufacturer: 'Sun Pharma',
        dosage: '1 capsule 3 times daily as prescribed',
      ),
      const Medicine(
        id: 'med_3',
        name: 'Cetirizine 10mg',
        category: 'Allergy',
        description: 'Non-drowsy antihistamine for seasonal allergies, cold symptoms, and itching.',
        price: 45.00,
        stock: 200,
        requiresPrescription: false,
        manufacturer: 'Dr. Reddy’s Labs',
        dosage: '1 tablet once daily at bedtime',
      ),
      const Medicine(
        id: 'med_4',
        name: 'Omeprazole 20mg',
        category: 'Digestive',
        description: 'Proton pump inhibitor for acid reflux, heartburn, and stomach ulcers.',
        price: 85.00,
        stock: 95,
        requiresPrescription: false,
        manufacturer: 'Lupin Pharma',
        dosage: '1 capsule once daily before breakfast',
      ),
      const Medicine(
        id: 'med_5',
        name: 'Vitamin D3 60,000 IU',
        category: 'Supplements',
        description: 'High-potency cholecalciferol capsules to support bone health and immunity.',
        price: 140.00,
        stock: 120,
        requiresPrescription: false,
        manufacturer: 'Torrent Pharma',
        dosage: '1 capsule weekly with milk',
      ),
      const Medicine(
        id: 'med_6',
        name: 'Azithromycin 500mg',
        category: 'Antibiotics',
        description: 'Macrolide antibiotic commonly used for respiratory tract and skin infections.',
        price: 135.00,
        stock: 60,
        requiresPrescription: true,
        manufacturer: 'Zydus Cadila',
        dosage: '1 tablet daily for 3 to 5 days',
      ),
      const Medicine(
        id: 'med_7',
        name: 'Ayurvedic Cough Syrup 100ml',
        category: 'Cold & Cough',
        description: 'Natural herbal syrup with Tulsi, Honey, and Mulethi for dry and chesty coughs.',
        price: 95.00,
        stock: 110,
        requiresPrescription: false,
        manufacturer: 'Dabur Healthcare',
        dosage: '2 teaspoons (10ml) thrice daily',
      ),
    ]);

    // Sample initial order
    _orders.add(
      MedicineOrder(
        id: 'order_1001',
        patientId: 'patient_default',
        items: [
          const CartItem(
            medicineId: 'med_1',
            name: 'Paracetamol 650mg',
            price: 32.50,
            quantity: 2,
          ),
          const CartItem(
            medicineId: 'med_5',
            name: 'Vitamin D3 60,000 IU',
            price: 140.00,
            quantity: 1,
          ),
        ],
        total: 205.00,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    );
  }

  @override
  Stream<List<Medicine>> watchMedicines({String? category, String? search}) async* {
    List<Medicine> filter(List<Medicine> list) {
      return list.where((m) {
        if (category != null &&
            category.isNotEmpty &&
            category.toLowerCase() != 'all' &&
            m.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
        if (search != null && search.isNotEmpty) {
          final query = search.toLowerCase();
          final matchesName = m.name.toLowerCase().contains(query);
          final matchesCat = m.category.toLowerCase().contains(query);
          final matchesDesc = m.description.toLowerCase().contains(query);
          if (!matchesName && !matchesCat && !matchesDesc) return false;
        }
        return true;
      }).toList();
    }

    yield filter(_medicines);
    yield* _medicinesController.stream.map(filter);
  }

  @override
  Future<Medicine?> getMedicine(String medicineId) async {
    try {
      return _medicines.firstWhere((m) => m.id == medicineId);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<List<CartItem>> watchCart(String patientId) async* {
    List<CartItem> cart() => _carts[patientId] ?? const <CartItem>[];
    yield cart();
    yield* _cartController.stream.map((_) => cart());
  }

  @override
  Future<void> addToCart({
    required String patientId,
    required Medicine medicine,
  }) async {
    final list = _carts.putIfAbsent(patientId, () => <CartItem>[]);
    final index = list.indexWhere((item) => item.medicineId == medicine.id);
    if (index >= 0) {
      list[index] = list[index].copyWith(quantity: list[index].quantity + 1);
    } else {
      list.add(
        CartItem(
          medicineId: medicine.id,
          name: medicine.name,
          price: medicine.price,
          quantity: 1,
          imageUrl: medicine.imageUrl,
          requiresPrescription: medicine.requiresPrescription,
        ),
      );
    }
    _cartController.add(_carts);
  }

  @override
  Future<void> updateQuantity({
    required String patientId,
    required String medicineId,
    required int quantity,
  }) async {
    final list = _carts[patientId];
    if (list == null) return;
    if (quantity <= 0) {
      list.removeWhere((item) => item.medicineId == medicineId);
    } else {
      final index = list.indexWhere((item) => item.medicineId == medicineId);
      if (index >= 0) {
        list[index] = list[index].copyWith(quantity: quantity);
      }
    }
    _cartController.add(_carts);
  }

  @override
  Future<void> removeFromCart({
    required String patientId,
    required String medicineId,
  }) async {
    final list = _carts[patientId];
    if (list != null) {
      list.removeWhere((item) => item.medicineId == medicineId);
      _cartController.add(_carts);
    }
  }

  @override
  Future<void> placeOrder({
    required String patientId,
    String? prescriptionRecordId,
  }) async {
    final list = _carts[patientId] ?? <CartItem>[];
    if (list.isEmpty) return;

    final total = list.fold<num>(0, (sum, item) => sum + item.total);
    final order = MedicineOrder(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      items: List<CartItem>.from(list),
      total: total,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      prescriptionRecordId: prescriptionRecordId,
    );

    _orders.insert(0, order);
    _carts[patientId]?.clear();
    _cartController.add(_carts);
    _ordersController.add(_orders);
  }

  @override
  Stream<List<MedicineOrder>> watchOrders(String patientId) async* {
    List<MedicineOrder> forPatient() {
      return _orders.where((o) => o.patientId == patientId || o.patientId == 'patient_default').toList();
    }

    yield forPatient();
    yield* _ordersController.stream.map((_) => forPatient());
  }
}
