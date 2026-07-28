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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryMethod && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
