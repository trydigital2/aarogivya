class CartItem {
  const CartItem({
    required this.medicineId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.requiresPrescription = false,
  });

  final String medicineId;
  final String name;
  final num price;
  final int quantity;
  final String? imageUrl;
  final bool requiresPrescription;

  num get total => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        medicineId: medicineId,
        name: name,
        price: price,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl,
        requiresPrescription: requiresPrescription,
      );
}
