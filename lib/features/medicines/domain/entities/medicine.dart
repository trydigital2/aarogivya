import 'package:aarogivya/core/utils/firestore_values.dart';

class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stock,
    required this.requiresPrescription,
    this.manufacturer,
    this.imageUrl,
    this.dosage,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final num price;
  final int stock;
  final bool requiresPrescription;
  final String? manufacturer;
  final String? imageUrl;
  final String? dosage;

  factory Medicine.fromMap(String id, Map<String, dynamic> map) {
    return Medicine(
      id: id,
      name: FirestoreValues.string(map['name'], 'Medicine'),
      category: FirestoreValues.string(map['category'], 'General'),
      description: FirestoreValues.string(map['description']),
      price: FirestoreValues.number(map['price']),
      stock: FirestoreValues.number(map['stock']).toInt(),
      requiresPrescription:
          FirestoreValues.boolean(map['requiresPrescription']),
      manufacturer: map['manufacturer'] as String?,
      imageUrl: map['imageUrl'] as String?,
      dosage: map['dosage'] as String?,
    );
  }
}
