import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../../products/controllers/admin_products_controller.dart';
import '../../categories/controllers/admin_categories_controller.dart';
import '../../orders/controllers/admin_orders_controller.dart';
import '../../activity_logs/controllers/admin_logs_controller.dart';
import '../../banners/controllers/admin_banners_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
    Get.lazyPut<AdminProductsController>(() => AdminProductsController());
    Get.lazyPut<AdminCategoriesController>(() => AdminCategoriesController());
    Get.lazyPut<AdminOrdersController>(() => AdminOrdersController());
    Get.lazyPut<AdminLogsController>(() => AdminLogsController());
    Get.lazyPut<AdminBannersController>(() => AdminBannersController());
  }
}
