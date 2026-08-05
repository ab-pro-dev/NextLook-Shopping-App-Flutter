import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../application/address_providers.dart';
import 'address_form_bottom_sheet.dart';

class AddressSelectionBottomSheet extends ConsumerWidget {
  const AddressSelectionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddressSelectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressListNotifierProvider);
    final selectedAddress = ref.watch(selectedCheckoutAddressProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Shipping Address',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address List
          Flexible(
            child: addressesAsync.when(
              data: (addresses) {
                if (addresses.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No saved addresses found.',
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final isSelected = selectedAddress?.id == address.id;

                    return GestureDetector(
                      key: Key('select_address_card_${address.id}'),
                      onTap: () {
                        ref.read(selectedCheckoutAddressProvider.notifier).selectAddress(address);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.04)
                              : const Color(0xFFF8F9FC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selection Radio Icon
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected ? AppColors.primary : Colors.grey[400],
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Address Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        address.fullName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      if (address.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
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
                                  const SizedBox(height: 4),
                                  Text(
                                    address.phone,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    address.formattedAddress,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.dark,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Edit Button
                            IconButton(
                              key: Key('edit_address_button_${address.id}'),
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              color: Colors.grey[600],
                              onPressed: () {
                                Navigator.pop(context);
                                AddressFormBottomSheet.show(context, addressToEdit: address);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Failed to load addresses: $err',
                    style: GoogleFonts.poppins(color: AppColors.accent),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add New Address Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              key: const Key('add_new_address_option_button'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              label: Text(
                'Add New Address',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                AddressFormBottomSheet.show(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
