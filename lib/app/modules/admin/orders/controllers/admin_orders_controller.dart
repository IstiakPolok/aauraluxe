import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/order_api.dart';
import 'package:aauraluxe/app/data/providers/activity_log_api.dart';

class AdminOrdersController extends GetxController {
  final OrderApi _orderApi = Get.find<OrderApi>();
  final ActivityLogApi _activityLogApi = Get.put(ActivityLogApi());

  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  
  final RxString selectedStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final list = await _orderApi.getAllOrders(
        status: selectedStatus.value,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      orders.value = list;
    } catch (e) {
      print('Admin orders load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterStatus(String status) {
    selectedStatus.value = status;
    loadOrders();
  }

  void search(String val) {
    searchQuery.value = val;
    loadOrders();
  }

  Future<void> updateStatus(int orderId, String newStatus) async {
    isLoading.value = true;
    try {
      await _orderApi.updateOrderStatus(orderId, newStatus);
      
      // Log this action
      await _activityLogApi.logAction(
        action: 'updated_order_status_to_$newStatus',
        entityType: 'order',
        entityId: orderId.toString(),
      );

      Get.snackbar('Status Updated', 'Order #$orderId is now $newStatus.', snackPosition: SnackPosition.BOTTOM);
      loadOrders();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
