import 'package:get/get.dart';
import '../controllers/admin_logs_controller.dart';

class AdminLogsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminLogsController>(() => AdminLogsController());
  }
}
