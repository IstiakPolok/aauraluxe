import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/product_api.dart';
import 'package:aauraluxe/app/data/providers/order_api.dart';
import 'package:aauraluxe/app/data/providers/auth_api.dart';

class AdminDashboardController extends GetxController {
  final OrderApi _orderApi = Get.put(OrderApi());
  final ProductApi _productApi = Get.put(ProductApi());
  final AuthApi _authApi = Get.put(AuthApi());

  final RxInt currentTabIndex = 0.obs;

  final RxDouble totalSales = 0.0.obs;
  final RxInt totalOrdersCount = 0.obs;
  final RxInt totalProductsCount = 0.obs;
  final RxInt totalUsersCount = 0.obs;
  
  final RxList<Order> recentOrders = <Order>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    isLoading.value = true;
    try {
      // Load orders
      final orders = await _orderApi.getAllOrders();
      totalOrdersCount.value = orders.length;
      recentOrders.value = orders.take(5).toList();
      
      // Calculate sales from delivered orders
      double sales = 0.0;
      for (var order in orders) {
        if (order.status.toLowerCase() == 'delivered') {
          sales += order.totalAmount;
        }
      }
      totalSales.value = sales;

      // Load products count
      final products = await _productApi.getProducts();
      totalProductsCount.value = products.length;

      // Load users/profiles count
      final profiles = await _authApi.getAllProfiles();
      totalUsersCount.value = profiles.length;
    } catch (e) {
      print('Failed to load dashboard metrics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(int index) {
    currentTabIndex.value = index;
  }
}
