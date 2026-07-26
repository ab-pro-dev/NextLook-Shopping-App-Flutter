class DeliveryMethod {
  final String id;
  final String label;
  final String estimatedDays;
  final double price;

  const DeliveryMethod({
    required this.id,
    required this.label,
    required this.estimatedDays,
    required this.price,
  });

  static const List<DeliveryMethod> availableMethods = [
    DeliveryMethod(
      id: 'standard',
      label: 'Standard Delivery',
      estimatedDays: '3-5 days',
      price: 150.0,
    ),
    DeliveryMethod(
      id: 'express',
      label: 'Express Delivery',
      estimatedDays: '1-2 days',
      price: 350.0,
    ),
  ];

  static DeliveryMethod get defaultMethod => availableMethods.first;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryMethod && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
