import 'package:get/get.dart';
import '../controllers/order_tracking_controller.dart';

class OrderTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderTrackingController>(() => OrderTrackingController());
  }
}
