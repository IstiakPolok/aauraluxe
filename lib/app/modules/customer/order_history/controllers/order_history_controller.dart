import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/order_api.dart';
import 'package:aauraluxe/app/modules/auth/controllers/auth_controller.dart';

class OrderHistoryController extends GetxController {
  final OrderApi _orderApi = Get.put(OrderApi());
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrderHistory();
  }

  Future<void> loadOrderHistory() async {
    final userId = _authController.profile?.id;
    if (userId == null) return;

    isLoading.value = true;
    try {
      final list = await _orderApi.getUserOrders(userId);
      orders.value = list;
    } catch (e) {
      print('Failed to load order history: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
