import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/success_toast.dart';
import '../application/address_providers.dart';
import '../data/address_model.dart';

class AddressFormBottomSheet extends ConsumerStatefulWidget {
  final Address? addressToEdit;

  const AddressFormBottomSheet({super.key, this.addressToEdit});

  static Future<Address?> show(BuildContext context, {Address? addressToEdit}) {
    return showModalBottomSheet<Address>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddressFormBottomSheet(addressToEdit: addressToEdit),
    );
  }

  @override
  ConsumerState<AddressFormBottomSheet> createState() => _AddressFormBottomSheetState();
}

class _AddressFormBottomSheetState extends ConsumerState<AddressFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _regionController;
  late final TextEditingController _countryController;
  late bool _isDefault;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final address = widget.addressToEdit;
    _fullNameController = TextEditingController(text: address?.fullName ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _addressLine1Controller = TextEditingController(text: address?.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: address?.addressLine2 ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _regionController = TextEditingController(text: address?.region ?? '');
    _countryController = TextEditingController(text: address?.country ?? 'United States');
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final notifier = ref.read(addressListNotifierProvider.notifier);
      late final Address savedAddress;

      if (widget.addressToEdit != null) {
        savedAddress = await notifier.updateAddress(
          id: widget.addressToEdit!.id,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          region: _regionController.text.trim(),
          country: _countryController.text.trim(),
          isDefault: _isDefault,
        );
      } else {
        savedAddress = await notifier.createAddress(
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          region: _regionController.text.trim(),
          country: _countryController.text.trim(),
          isDefault: _isDefault,
        );
      }

      // Auto select the created/edited address for current checkout
      ref.read(selectedCheckoutAddressProvider.notifier).selectAddress(savedAddress);

      if (mounted) {
        Navigator.pop(context, savedAddress);
        AppToast.show(
          context,
          title: widget.addressToEdit != null ? 'Address Updated' : 'Address Added',
          subtitle: savedAddress.fullName,
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.accent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save address'), backgroundColor: AppColors.accent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEditing = widget.addressToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Shipping Address' : 'Add Shipping Address',
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
              const SizedBox(height: 16),

              // Full Name
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                hint: 'John Doe',
                validator: (val) => val == null || val.trim().isEmpty ? 'Full name is required' : null,
              ),
              const SizedBox(height: 12),

              // Phone Number
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+1 234 567 8900',
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.trim().isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 12),

              // Address Line 1
              _buildTextField(
                controller: _addressLine1Controller,
                label: 'Address Line 1',
                hint: '123 Main Street',
                validator: (val) => val == null || val.trim().isEmpty ? 'Address line 1 is required' : null,
              ),
              const SizedBox(height: 12),

              // Address Line 2
              _buildTextField(
                controller: _addressLine2Controller,
                label: 'Address Line 2 (Optional)',
                hint: 'Apt, Suite, Building, etc.',
              ),
              const SizedBox(height: 12),

              // City & Region (Side by side)
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'New York',
                      validator: (val) => val == null || val.trim().isEmpty ? 'City is required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _regionController,
                      label: 'State / Region',
                      hint: 'NY',
                      validator: (val) => val == null || val.trim().isEmpty ? 'State/region is required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Country
              _buildTextField(
                controller: _countryController,
                label: 'Country',
                hint: 'United States',
                validator: (val) => val == null || val.trim().isEmpty ? 'Country is required' : null,
              ),
              const SizedBox(height: 12),

              // Set as default checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: Text(
                  'Set as default address',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.dark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _isDefault,
                onChanged: (val) {
                  setState(() {
                    _isDefault = val ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('save_address_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          isEditing ? 'Update Address' : 'Save Address',
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.dark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF8F9FC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
