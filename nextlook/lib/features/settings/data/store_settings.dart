import '../../checkout/data/delivery_method.dart';

class StoreSettings {
  final String id;
  final String standardDeliveryLabel;
  final String standardDeliveryDays;
  final double standardDeliveryPrice;
  final String expressDeliveryLabel;
  final String expressDeliveryDays;
  final double expressDeliveryPrice;
  final double taxRatePercent;

  const StoreSettings({
    required this.id,
    required this.standardDeliveryLabel,
    required this.standardDeliveryDays,
    required this.standardDeliveryPrice,
    required this.expressDeliveryLabel,
    required this.expressDeliveryDays,
    required this.expressDeliveryPrice,
    required this.taxRatePercent,
  });

  factory StoreSettings.fromJson(Map<String, dynamic> json) {
    return StoreSettings(
      id: json['id'] as String? ?? '',
      standardDeliveryLabel: json['standardDeliveryLabel'] as String? ?? 'Standard Delivery',
      standardDeliveryDays: json['standardDeliveryDays'] as String? ?? '3-5 days',
      standardDeliveryPrice: (json['standardDeliveryPrice'] as num?)?.toDouble() ?? 150.0,
      expressDeliveryLabel: json['expressDeliveryLabel'] as String? ?? 'Express Delivery',
      expressDeliveryDays: json['expressDeliveryDays'] as String? ?? '1-2 days',
      expressDeliveryPrice: (json['expressDeliveryPrice'] as num?)?.toDouble() ?? 300.0,
      taxRatePercent: (json['taxRatePercent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Helper to convert StoreSettings into dynamic DeliveryMethod list
  List<DeliveryMethod> get deliveryMethods => [
        DeliveryMethod(
          id: 'standard',
          label: standardDeliveryLabel,
          estimatedDays: standardDeliveryDays,
          price: standardDeliveryPrice,
        ),
        DeliveryMethod(
          id: 'express',
          label: expressDeliveryLabel,
          estimatedDays: expressDeliveryDays,
          price: expressDeliveryPrice,
        ),
      ];
}
