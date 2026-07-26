import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../address/application/address_providers.dart';
import '../../address/data/address_model.dart';
import '../data/delivery_method.dart';

class CheckoutState {
  final Address? selectedAddress;
  final DeliveryMethod selectedDeliveryMethod;
  final String? selectedPaymentMethod;
  final int currentStep;

  const CheckoutState({
    this.selectedAddress,
    this.selectedDeliveryMethod = const DeliveryMethod(
      id: 'standard',
      label: 'Standard Delivery',
      estimatedDays: '3-5 days',
      price: 150.0,
    ),
    this.selectedPaymentMethod = 'Cash on Delivery',
    this.currentStep = 0,
  });

  CheckoutState copyWith({
    Address? selectedAddress,
    DeliveryMethod? selectedDeliveryMethod,
    String? selectedPaymentMethod,
    int? currentStep,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedDeliveryMethod: selectedDeliveryMethod ?? this.selectedDeliveryMethod,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class CheckoutSessionNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    final address = ref.read(selectedCheckoutAddressProvider);
    return CheckoutState(
      selectedAddress: address,
      selectedDeliveryMethod: DeliveryMethod.defaultMethod,
      currentStep: 0,
    );
  }

  void setAddress(Address address) {
    ref.read(selectedCheckoutAddressProvider.notifier).selectAddress(address);
    state = state.copyWith(selectedAddress: address);
  }

  void setDeliveryMethod(DeliveryMethod method) {
    state = state.copyWith(selectedDeliveryMethod: method);
  }

  void setPaymentMethod(String paymentMethod) {
    state = state.copyWith(selectedPaymentMethod: paymentMethod);
  }

  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      state = state.copyWith(currentStep: step);
    }
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void resetSession() {
    state = CheckoutState(
      selectedAddress: ref.read(selectedCheckoutAddressProvider),
      selectedDeliveryMethod: DeliveryMethod.defaultMethod,
      currentStep: 0,
    );
  }
}

final checkoutSessionProvider =
    NotifierProvider<CheckoutSessionNotifier, CheckoutState>(() {
  return CheckoutSessionNotifier();
});
