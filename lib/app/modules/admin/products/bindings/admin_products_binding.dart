import 'package:get/get.dart';
import '../controllers/admin_products_controller.dart';
import '../../categories/controllers/admin_categories_controller.dart';

class AdminProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminProductsController>(() => AdminProductsController());
    Get.lazyPut<AdminCategoriesController>(() => AdminCategoriesController());
  }
}
