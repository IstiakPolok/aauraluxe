import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/providers/api_client.dart';
import 'app_routes.dart';

// View Imports
import '../modules/auth/views/login_view.dart';
import '../modules/customer/home/views/home_view.dart';
import '../modules/customer/product_details/views/product_details_view.dart';
import '../modules/customer/cart/views/cart_view.dart';
import '../modules/customer/checkout/views/checkout_view.dart';
import '../modules/customer/order_tracking/views/order_tracking_view.dart';
import '../modules/customer/order_history/views/order_history_view.dart';
import '../modules/customer/category_products/views/category_products_view.dart';

import '../modules/admin/dashboard/views/admin_dashboard_view.dart';
import '../modules/admin/products/views/admin_products_view.dart';
import '../modules/admin/orders/views/admin_orders_view.dart';
import '../modules/admin/categories/views/admin_categories_view.dart';
import '../modules/admin/activity_logs/views/admin_logs_view.dart';
import '../modules/admin/users/views/admin_users_view.dart';

// Binding Imports
import '../modules/auth/bindings/login_binding.dart';
import '../modules/customer/home/bindings/home_binding.dart';
import '../modules/customer/product_details/bindings/product_details_binding.dart';
import '../modules/customer/cart/bindings/cart_binding.dart';
import '../modules/customer/checkout/bindings/checkout_binding.dart';
import '../modules/customer/order_tracking/bindings/order_tracking_binding.dart';
import '../modules/customer/order_history/bindings/order_history_binding.dart';
import '../modules/customer/category_products/bindings/category_products_binding.dart';

import '../modules/admin/dashboard/bindings/admin_dashboard_binding.dart';
import '../modules/admin/products/bindings/admin_products_binding.dart';
import '../modules/admin/orders/bindings/admin_orders_binding.dart';
import '../modules/admin/categories/bindings/admin_categories_binding.dart';
import '../modules/admin/activity_logs/bindings/admin_logs_binding.dart';
import '../modules/admin/users/bindings/admin_users_binding.dart';

// Middleware for Role Guards
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final client = Get.find<ApiClient>();
    if (!client.isAuthenticated) {
      Get.snackbar('Access Denied', 'Please log in to proceed.', snackPosition: SnackPosition.BOTTOM);
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    return null;
  }
}

class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final client = Get.find<ApiClient>();
    if (!client.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    if (!client.isAdmin) {
      Get.snackbar('Unauthorized', 'Access restricted to Admins only.', snackPosition: SnackPosition.BOTTOM);
      return const RouteSettings(name: AppRoutes.CUSTOMER_HOME);
    }
    return null;
  }
}

class StaffGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final client = Get.find<ApiClient>();
    if (!client.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    if (!client.isStaff) {
      Get.snackbar('Unauthorized', 'Access restricted to Staff and Admins.', snackPosition: SnackPosition.BOTTOM);
      return const RouteSettings(name: AppRoutes.CUSTOMER_HOME);
    }
    return null;
  }
}

class SuperAdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final client = Get.find<ApiClient>();
    if (!client.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }
    if (!client.isSuperAdmin) {
      Get.snackbar('Unauthorized', 'Access restricted to Super Admins only.', snackPosition: SnackPosition.BOTTOM);
      return const RouteSettings(name: AppRoutes.ADMIN_DASHBOARD);
    }
    return null;
  }
}

class AppPages {
  static const INITIAL = AppRoutes.CUSTOMER_HOME;

  static final routes = [
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    
    // Customer Screens
    GetPage(
      name: AppRoutes.CUSTOMER_HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.PRODUCT_DETAILS,
      page: () => const ProductDetailsView(),
      binding: ProductDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.CATEGORY_PRODUCTS,
      page: () => const CategoryProductsView(),
      binding: CategoryProductsBinding(),
    ),
    GetPage(
      name: AppRoutes.CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.ORDER_TRACKING,
      page: () => const OrderTrackingView(),
      binding: OrderTrackingBinding(),
    ),
    GetPage(
      name: AppRoutes.ORDER_HISTORY,
      page: () => const OrderHistoryView(),
      binding: OrderHistoryBinding(),
      middlewares: [AuthGuard()],
    ),

    // Admin Screens
    GetPage(
      name: AppRoutes.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
      middlewares: [StaffGuard()], // Admin & Staff can access dashboard summary
    ),
    GetPage(
      name: AppRoutes.ADMIN_PRODUCTS,
      page: () => const AdminProductsView(),
      binding: AdminProductsBinding(),
      middlewares: [AdminGuard()], // Only Admins can modify products
    ),
    GetPage(
      name: AppRoutes.ADMIN_ORDERS,
      page: () => const AdminOrdersView(),
      binding: AdminOrdersBinding(),
      middlewares: [StaffGuard()], // Staff can update order status
    ),
    GetPage(
      name: AppRoutes.ADMIN_CATEGORIES,
      page: () => const AdminCategoriesView(),
      binding: AdminCategoriesBinding(),
      middlewares: [AdminGuard()], // Only Admins can manage categories
    ),
    GetPage(
      name: AppRoutes.ADMIN_LOGS,
      page: () => const AdminLogsView(),
      binding: AdminLogsBinding(),
      middlewares: [SuperAdminGuard()], // Only Super Admin can view audit logs
    ),
    GetPage(
      name: AppRoutes.ADMIN_USERS,
      page: () => const AdminUsersView(),
      binding: AdminUsersBinding(),
      middlewares: [SuperAdminGuard()], // Only Super Admin can manage users
    ),
  ];
}
