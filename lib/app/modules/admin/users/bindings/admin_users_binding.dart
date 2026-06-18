import 'package:get/get.dart';
import 'package:aauraluxe/app/modules/admin/users/controllers/admin_users_controller.dart';
import 'package:aauraluxe/app/data/providers/auth_api.dart';

class AdminUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthApi>(() => AuthApi());
    Get.lazyPut<AdminUsersController>(() => AdminUsersController());
  }
}
