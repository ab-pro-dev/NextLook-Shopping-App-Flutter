import 'package:intl/intl.dart';

/// Centralized currency formatter for NextLook application.
/// Formats any price into Ethiopian Birr (ETB X,XXX) with thousands separators
/// and rounded to the nearest whole Birr (no decimals).
String formatPrice(num amount) {
  final roundedAmount = amount.round();
  final formatter = NumberFormat('#,##0', 'en_US');
  return 'ETB ${formatter.format(roundedAmount)}';
}
