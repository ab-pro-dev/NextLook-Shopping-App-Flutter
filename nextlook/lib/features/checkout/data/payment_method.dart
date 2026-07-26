// Skip Apple Pay for now given the local Ethiopian payment context.
// Flagged in case Apple Pay / Google Pay is needed in future international releases.
class PaymentMethodOption {
  final String id;
  final String label;
  final String iconName;

  const PaymentMethodOption({
    required this.id,
    required this.label,
    required this.iconName,
  });

  static const List<PaymentMethodOption> availableMethods = [
    PaymentMethodOption(
      id: 'card',
      label: 'Credit / Debit Card',
      iconName: 'credit_card',
    ),
    PaymentMethodOption(
      id: 'telebirr',
      label: 'TeleBirr',
      iconName: 'phone_android',
    ),
    PaymentMethodOption(
      id: 'chapa',
      label: 'Chapa',
      iconName: 'account_balance_wallet',
    ),
    PaymentMethodOption(
      id: 'cod',
      label: 'Cash on Delivery',
      iconName: 'payments',
    ),
  ];

  static PaymentMethodOption get defaultMethod =>
      availableMethods.firstWhere((m) => m.id == 'cod', orElse: () => availableMethods.last);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodOption && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
