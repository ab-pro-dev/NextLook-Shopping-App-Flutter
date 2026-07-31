import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/sign_in_required_view.dart';
import 'widgets/order_skeletons.dart';
import '../../auth/application/auth_providers.dart';
import '../application/order_providers.dart';
import '../data/order_model.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  static const List<Map<String, String>> _stages = [
    {'title': 'Order Confirmed', 'subtitle': 'Your order has been placed', 'status': 'PENDING'},
    {'title': 'Packed', 'subtitle': 'Items packed and ready to ship', 'status': 'PROCESSING'},
    {'title': 'Shipped', 'subtitle': 'Package transferred to carrier', 'status': 'SHIPPED'},
    {'title': 'Out for Delivery', 'subtitle': 'Courier is on the way', 'status': 'OUT_FOR_DELIVERY'},
    {'title': 'Delivered', 'subtitle': 'Package delivered to recipient', 'status': 'DELIVERED'},
  ];

  int _getCompletedStageIndex(String currentStatus) {
    switch (currentStatus) {
      case 'PENDING':
        return 0; // Stage 0 (Order Confirmed) is completed
      case 'PROCESSING':
        return 1; // Stage 0 & 1 completed
      case 'SHIPPED':
        return 2; // Stage 0, 1, 2 completed
      case 'OUT_FOR_DELIVERY':
        return 3; // Stage 0..3 completed
      case 'DELIVERED':
        return 4; // All 5 stages completed
      default:
        return 0;
    }
  }

  IconData _getPaymentIcon(String method) {
    final lower = method.toLowerCase();
    if (lower.contains('card')) return Icons.credit_card_rounded;
    if (lower.contains('telebirr')) return Icons.phone_android_rounded;
    if (lower.contains('chapa')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('cash') || lower.contains('cod')) return Icons.payments_rounded;
    return Icons.payment_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState is! AuthAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.dark, size: 20),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/orders');
              }
            },
          ),
          title: Text(
            'Order Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          centerTitle: true,
        ),
        body: const SignInRequiredView(
          title: 'Sign In Required',
          message: 'Please sign in to view order tracking details.',
          icon: Icons.location_on_outlined,
        ),
      );
    }

    final orderDetailAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.dark, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/orders');
            }
          },
        ),
        title: orderDetailAsync.when(
          data: (order) => Column(
            children: [
              Text(
                '#${order.orderNumber}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              // Calculated estimated delivery placeholder
              Text(
                'Est. Delivery: ${DateFormat('MMM dd').format(order.createdAt.add(const Duration(days: 4)))}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          loading: () => Text('Order Tracking', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          error: (_, __) => Text('Order Details', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        centerTitle: true,
      ),
      body: orderDetailAsync.when(
        data: (order) {
          final completedStageIdx = _getCompletedStageIndex(order.status);

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(orderDetailProvider(orderId));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TIMELINE SECTION
                  Text(
                    'Order Status',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(_stages.length, (index) {
                        final isCompleted = index <= completedStageIdx;
                        final isLast = index == _stages.length - 1;
                        final stageData = _stages[index];

                        // Find matching timestamp from statusHistory
                        final historyMatch = order.statusHistory.firstWhere(
                          (h) => h.status == stageData['status'],
                          orElse: () => OrderStatusHistory(
                            id: '',
                            orderId: '',
                            status: '',
                            createdAt: DateTime.fromMicrosecondsSinceEpoch(0),
                          ),
                        );

                        final String? timestampText = historyMatch.id.isNotEmpty
                            ? DateFormat('MMM dd • h:mm a').format(historyMatch.createdAt)
                            : null;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline Indicator Column
                              Column(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isCompleted ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: isCompleted
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          )
                                        : Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        color: isCompleted && index < completedStageIdx
                                            ? const Color(0xFF22C55E)
                                            : Colors.grey[300],
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(width: 14),

                              // Stage Label & Details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            stageData['title']!,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: isCompleted ? FontWeight.bold : FontWeight.w500,
                                              color: isCompleted ? AppColors.dark : Colors.grey[500],
                                            ),
                                          ),
                                          if (timestampText != null)
                                            Text(
                                              timestampText,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        stageData['subtitle']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: isCompleted ? Colors.grey[600] : Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. ORDER ITEMS SUMMARY
                  Text(
                    'Order Items (${order.items.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: order.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.productThumbnailUrl.isNotEmpty
                                  ? Image.network(
                                      item.productThumbnailUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.shopping_bag_outlined, size: 20),
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.shopping_bag_outlined, size: 20),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.colorName} • Size: ${item.sizeLabel}  •  Qty: ${item.quantity}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatPrice(item.lineTotal),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. SHIPPING ADDRESS SUMMARY
                  Text(
                    'Shipping Address',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${order.shippingFullName}  (${order.shippingPhone})',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.shippingAddressLine1}${order.shippingAddressLine2 != null && order.shippingAddressLine2!.isNotEmpty ? ', ${order.shippingAddressLine2}' : ''}, ${order.shippingCity}, ${order.shippingRegion}, ${order.shippingCountry}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. DELIVERY & PAYMENT METHOD
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Method',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Text(
                                order.deliveryMethodLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Method',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getPaymentIcon(order.paymentMethod),
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      order.paymentMethod,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.dark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 5. PRICE BREAKDOWN
                  Text(
                    'Payment Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', formatPrice(order.subtotal)),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Shipping', formatPrice(order.shippingCost)),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Tax', formatPrice(order.tax)),
                        const Divider(height: 20),
                        _buildSummaryRow(
                          'Total',
                          formatPrice(order.total),
                          isBold: true,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const OrderTrackingSkeleton(),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.accent),
                const SizedBox(height: 12),
                Text(
                  'Order Not Found',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unable to load order details for ID: $orderId',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  key: const Key('back_to_orders_error_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.go('/orders'),
                  child: Text(
                    'Back to Orders',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.dark : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 17 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.dark,
          ),
        ),
      ],
    );
  }
}
