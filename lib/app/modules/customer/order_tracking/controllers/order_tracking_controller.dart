import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/order_api.dart';

class OrderTrackingController extends GetxController {
  final OrderApi _orderApi = Get.put(OrderApi());

  final formKey = GlobalKey<FormState>();
  final idController = TextEditingController();
  final phoneController = TextEditingController();

  final Rxn<Order> trackedOrder = Rxn<Order>();
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-populate if redirected from checkout
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['orderId'] != null) idController.text = args['orderId'].toString();
      if (args['phone'] != null) phoneController.text = args['phone'].toString();
      searchOrder();
    }
  }

  @override
  void onClose() {
    idController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> searchOrder() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    hasSearched.value = true;
    trackedOrder.value = null;

    final orderId = int.tryParse(idController.text.trim());
    final phone = phoneController.text.trim();

    if (orderId == null) {
      Get.snackbar('Input Error', 'Please enter a valid numeric Order ID.', snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      return;
    }

    try {
      final order = await _orderApi.trackGuestOrder(orderId, phone);
      trackedOrder.value = order;
      if (order == null) {
        Get.snackbar('Not Found', 'No order matches that ID and Phone combination.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to retrieve order: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Get status step index for stepper
  int get statusStep {
    if (trackedOrder.value == null) return 0;
    
    final status = trackedOrder.value!.status.toLowerCase();
    switch (status) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'processing':
        return 2;
      case 'packed':
        return 3;
      case 'shipped':
        return 4;
      case 'delivered':
        return 5;
      case 'cancelled':
      default:
        return -1; // Special indicator
    }
  }
}
