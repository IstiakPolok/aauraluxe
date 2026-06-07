import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/theme.dart';
import 'app/data/providers/api_client.dart';
import 'app/modules/customer/cart/controllers/cart_controller.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize PostgREST ApiClient
  final apiClient = ApiClient();
  await Get.putAsync(() => apiClient.init());

  // 2. Bind Auth Controller (handles session check and roles)
  Get.put(AuthController(), permanent: true);

  // 3. Bind Cart Controller (keeps item count updated across views)
  Get.put(CartController(), permanent: true);

  runApp(const AuraLuxeApp());
}

class AuraLuxeApp extends StatelessWidget {
  const AuraLuxeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AuraLuxe Ecommerce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}
