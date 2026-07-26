import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../address/application/address_providers.dart';
import '../../address/presentation/address_form_bottom_sheet.dart';
import '../../address/presentation/address_selection_bottom_sheet.dart';
import '../../cart/application/cart_providers.dart';
import '../../orders/application/order_providers.dart';
import '../application/checkout_providers.dart';
import '../data/delivery_method.dart';
import '../data/payment_method.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const List<String> _stepTitles = ['Address', 'Delivery', 'Payment', 'Review'];
  bool _isPlacingOrder = false;

  IconData _getPaymentIcon(String method) {
    final lower = method.toLowerCase();
    if (lower.contains('card')) return Icons.credit_card_rounded;
    if (lower.contains('telebirr')) return Icons.phone_android_rounded;
    if (lower.contains('chapa')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('cash') || lower.contains('cod')) return Icons.payments_rounded;
    return Icons.payment_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutSessionProvider);
    final checkoutNotifier = ref.read(checkoutSessionProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.dark, size: 20),
          onPressed: () {
            if (checkoutState.currentStep > 0) {
              checkoutNotifier.previousStep();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. STEPPER PROGRESS BAR
          _buildStepProgressIndicator(checkoutState.currentStep),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // 2. STEP CONTENT AREA
          Expanded(
            child: _buildCurrentStepBody(context, ref, checkoutState, checkoutNotifier),
          ),
        ],
      ),
    );
  }

  /// Horizontal 4-step Progress Indicator matching design specs
  Widget _buildStepProgressIndicator(int currentStep) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_stepTitles.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          Color circleColor;
          Color textColor;
          Widget circleChild;

          if (isCompleted) {
            circleColor = AppColors.primary;
            textColor = AppColors.primary;
            circleChild = const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 14,
            );
          } else if (isCurrent) {
            circleColor = AppColors.primary;
            textColor = AppColors.primary;
            circleChild = Text(
              '${index + 1}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          } else {
            circleColor = const Color(0xFFE5E7EB);
            textColor = Colors.grey[400]!;
            circleChild = Text(
              '${index + 1}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            );
          }

          return Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: circleChild,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stepTitles[index],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                if (index < _stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18, left: 4, right: 4),
                      color: isCompleted ? AppColors.primary : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Swappable step body
  Widget _buildCurrentStepBody(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkoutState,
    CheckoutSessionNotifier checkoutNotifier,
  ) {
    switch (checkoutState.currentStep) {
      case 0:
        return _buildAddressStepContent(context, ref, checkoutState, checkoutNotifier);
      case 1:
        return _buildDeliveryStepContent(context, ref, checkoutState, checkoutNotifier);
      case 2:
        return _buildPaymentStepContent(context, ref, checkoutState, checkoutNotifier);
      case 3:
        return _buildReviewStepContent(context, ref, checkoutState, checkoutNotifier);
      default:
        return _buildAddressStepContent(context, ref, checkoutState, checkoutNotifier);
    }
  }

  /// STEP 0: Address Selection Content
  Widget _buildAddressStepContent(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkoutState,
    CheckoutSessionNotifier checkoutNotifier,
  ) {
    final addressesAsync = ref.watch(addressListNotifierProvider);
    final selectedAddress = checkoutState.selectedAddress;

    return addressesAsync.when(
      data: (addresses) {
        final effectiveAddress = selectedAddress ??
            (addresses.isNotEmpty
                ? addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first)
                : null);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping Address',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  if (addresses.isNotEmpty)
                    GestureDetector(
                      key: const Key('change_address_link'),
                      onTap: () => AddressSelectionBottomSheet.show(context),
                      child: Text(
                        'Change',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              if (effectiveAddress != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                effectiveAddress.fullName,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                              if (effectiveAddress.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'DEFAULT',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        effectiveAddress.phone,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        effectiveAddress.formattedAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.dark,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.location_off_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No Shipping Address Saved',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please add a shipping address to proceed with your checkout.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        key: const Key('add_address_empty_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, color: Colors.white),
                        label: Text(
                          'Add Address',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => AddressFormBottomSheet.show(context),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('checkout_continue_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: effectiveAddress != null ? AppColors.primary : Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (effectiveAddress == null) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please select or add a shipping address to continue',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: AppColors.dark,
                        ),
                      );
                      return;
                    }
                    if (selectedAddress == null) {
                      checkoutNotifier.setAddress(effectiveAddress);
                    }
                    checkoutNotifier.nextStep();
                  },
                  child: Text(
                    'Continue to Delivery',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: effectiveAddress != null ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load addresses',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.dark),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.accent),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(addressListNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// STEP 1: Delivery Method Step Content
  Widget _buildDeliveryStepContent(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkoutState,
    CheckoutSessionNotifier checkoutNotifier,
  ) {
    final selectedMethod = checkoutState.selectedDeliveryMethod;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Method',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 14),

          ...DeliveryMethod.availableMethods.map((method) {
            final isSelected = selectedMethod.id == method.id;

            return GestureDetector(
              key: Key('delivery_option_${method.id}'),
              onTap: () {
                checkoutNotifier.setDeliveryMethod(method);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.label,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.estimatedDays,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          formatPrice(method.price),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected ? AppColors.primary : Colors.grey[400],
                          size: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('continue_to_payment_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                checkoutNotifier.nextStep();
              },
              child: Text(
                'Continue to Payment',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Center(
            child: TextButton.icon(
              onPressed: () => checkoutNotifier.previousStep(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                'Back to Previous Step',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STEP 2: Payment Method Step Content
  Widget _buildPaymentStepContent(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkoutState,
    CheckoutSessionNotifier checkoutNotifier,
  ) {
    final selectedPayment = checkoutState.selectedPaymentMethod ?? 'Cash on Delivery';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 14),

          ...PaymentMethodOption.availableMethods.map((option) {
            final isSelected = selectedPayment == option.label || selectedPayment == option.id;

            return GestureDetector(
              key: Key('payment_option_${option.id}'),
              onTap: () {
                checkoutNotifier.setPaymentMethod(option.label);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : const Color(0xFFF4F5F8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getPaymentIcon(option.label),
                        color: isSelected ? AppColors.primary : AppColors.dark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        option.label,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.primary : Colors.grey[400],
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('continue_to_review_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedPayment.isNotEmpty ? AppColors.primary : Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: selectedPayment.isEmpty ? null : () => checkoutNotifier.nextStep(),
              child: Text(
                'Continue to Review',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: selectedPayment.isNotEmpty ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Center(
            child: TextButton.icon(
              onPressed: () => checkoutNotifier.previousStep(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                'Back to Delivery',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STEP 3: Review Step Content
  Widget _buildReviewStepContent(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkoutState,
    CheckoutSessionNotifier checkoutNotifier,
  ) {
    final cartAsync = ref.watch(cartProvider);
    final selectedAddress = checkoutState.selectedAddress;
    final selectedDelivery = checkoutState.selectedDeliveryMethod;
    final selectedPayment = checkoutState.selectedPaymentMethod ?? 'Cash on Delivery';

    return cartAsync.when(
      data: (cart) {
        const double taxPercentage = 0.0;
        final double subtotal = cart.subtotal;
        final double shipping = selectedDelivery.price;
        final double tax = subtotal * taxPercentage;
        final double total = subtotal + shipping + tax;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ORDER SUMMARY (Cart Items)
              Text(
                'Order Summary',
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
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.thumbnailUrl != null
                              ? Image.network(
                                  item.thumbnailUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported, size: 20),
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
                                item.name,
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

              // 2. SHIPPING ADDRESS SUMMARY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipping Address',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  GestureDetector(
                    key: const Key('edit_address_review_link'),
                    onTap: () => checkoutNotifier.setStep(0),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (selectedAddress != null)
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
                        '${selectedAddress.fullName}  (${selectedAddress.phone})',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedAddress.formattedAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // 3. DELIVERY METHOD SUMMARY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Method',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  GestureDetector(
                    key: const Key('edit_delivery_review_link'),
                    onTap: () => checkoutNotifier.setStep(1),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDelivery.label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedDelivery.estimatedDays,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatPrice(selectedDelivery.price),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. PAYMENT METHOD SUMMARY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Method',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  GestureDetector(
                    key: const Key('edit_payment_review_link'),
                    onTap: () => checkoutNotifier.setStep(2),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
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
                child: Row(
                  children: [
                    Icon(
                      _getPaymentIcon(selectedPayment),
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      selectedPayment,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. PRICE BREAKDOWN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', formatPrice(subtotal)),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Shipping', formatPrice(shipping)),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Tax', formatPrice(tax)),
                    const Divider(height: 20),
                    _buildSummaryRow(
                      'Total',
                      formatPrice(total),
                      isBold: true,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 6. PLACE ORDER BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('place_order_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isPlacingOrder
                      ? null
                      : () => _handlePlaceOrder(context, ref, checkoutState, checkoutNotifier),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Place Order',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (err, stack) => Center(
        child: Text('Failed to load cart summary: $err', style: GoogleFonts.poppins(color: AppColors.accent)),
      ),
    );
  }

  Future<void> _handlePlaceOrder(
    BuildContext context,
    WidgetRef ref,
    CheckoutState checkoutState,
    CheckoutSessionNotifier checkoutNotifier,
  ) async {
    if (_isPlacingOrder) return;

    final selectedAddress = checkoutState.selectedAddress;
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shipping address is required.', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.dark,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final createdOrder = await orderRepo.createOrder(
        addressId: selectedAddress.id,
        deliveryMethodLabel: checkoutState.selectedDeliveryMethod.label,
        deliveryMethodPrice: checkoutState.selectedDeliveryMethod.price,
        paymentMethod: checkoutState.selectedPaymentMethod ?? 'Cash on Delivery',
      );

      // Reset checkout session state
      checkoutNotifier.resetSession();

      // Invalidate cart provider so cart refreshes to empty
      ref.invalidate(cartProvider);

      if (!mounted) return;
      setState(() {
        _isPlacingOrder = false;
      });

      // Navigate to Order Success Screen
      context.go(
        '/order-success',
        extra: {
          'orderNumber': createdOrder.orderNumber,
          'orderId': createdOrder.id,
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isPlacingOrder = false;
      });

      if (e.statusCode == 409) {
        // Stock Conflict Error -> Show dialog and route back to Cart
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Stock Conflict',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.dark),
            ),
            content: Text(
              e.message,
              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.dark),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.invalidate(cartProvider);
                  context.go('/cart');
                },
                child: Text(
                  'Return to Cart',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message, style: GoogleFonts.poppins()),
            backgroundColor: AppColors.dark,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPlacingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order. Please try again.', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.dark,
        ),
      );
    }
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.dark : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? AppColors.dark,
          ),
        ),
      ],
    );
  }
}
