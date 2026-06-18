import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aauraluxe/app/core/theme.dart';
import 'package:aauraluxe/app/shared/responsive_layout.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'package:aauraluxe/app/modules/auth/controllers/auth_controller.dart';
import 'package:aauraluxe/app/routes/app_routes.dart';

// Import subviews
import '../../products/views/admin_products_view.dart';
import '../../categories/views/admin_categories_view.dart';
import '../../orders/views/admin_orders_view.dart';
import '../../activity_logs/views/admin_logs_view.dart';
import '../../banners/views/admin_banners_view.dart';
import '../../users/views/admin_users_view.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final isSuperAdmin = authController.profile?.isSuperAdmin ?? false;

    // Sub-panels mapped to indexes
    final List<Widget> panels = [
      _buildOverviewTab(context),
      const AdminProductsView(),
      const AdminCategoriesView(),
      const AdminOrdersView(),
      const AdminBannersView(),
      if (isSuperAdmin)
        const AdminUsersView()
      else
        const Center(child: Text('Unauthorized access')),
      if (isSuperAdmin)
        const AdminLogsView()
      else
        const Center(child: Text('Unauthorized access')),
    ];

    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Overview', 'icon': Icons.dashboard_outlined},
      {'title': 'Products', 'icon': Icons.inventory_2_outlined},
      {'title': 'Categories', 'icon': Icons.category_outlined},
      {'title': 'Orders', 'icon': Icons.shopping_bag_outlined},
      {'title': 'Banners', 'icon': Icons.view_carousel_outlined},
      if (isSuperAdmin)
        {'title': 'Users', 'icon': Icons.people_alt_outlined},
      if (isSuperAdmin)
        {'title': 'Activity Logs', 'icon': Icons.history_edu_outlined},
    ];

    return ResponsiveLayout(
      mobile: _buildMobileLayout(context, panels, menuItems),
      tablet: _buildTabletLayout(context, panels, menuItems),
      desktop: _buildDesktopLayout(context, panels, menuItems),
    );
  }

  // --- MOBILE LAYOUT (Bottom Navigation) ---
  Widget _buildMobileLayout(
    BuildContext context,
    List<Widget> panels,
    List<Map<String, dynamic>> menuItems,
  ) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            menuItems[controller.currentTabIndex.value]['title'] as String,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'View Shop',
            onPressed: () => Get.offAllNamed(AppRoutes.CUSTOMER_HOME),
          ),
        ],
      ),
      body: Obx(() => panels[controller.currentTabIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentTabIndex.value,
          onTap: (idx) => controller.switchTab(idx),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          backgroundColor: Colors.white,
          items: menuItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item['icon'] as IconData),
                  label: item['title'] as String,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // --- TABLET LAYOUT (Side Drawer Navigation) ---
  Widget _buildTabletLayout(
    BuildContext context,
    List<Widget> panels,
    List<Map<String, dynamic>> menuItems,
  ) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            menuItems[controller.currentTabIndex.value]['title'] as String,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => Get.offAllNamed(AppRoutes.CUSTOMER_HOME),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: ListView(
                children: List.generate(menuItems.length, (index) {
                  final item = menuItems[index];
                  return Obx(() {
                    final isSelected =
                        controller.currentTabIndex.value == index;
                    return ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? AppTheme.accent
                            : AppTheme.textSecondary,
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppTheme.accent
                              : AppTheme.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () {
                        controller.switchTab(index);
                        scaffoldKey.currentState?.closeDrawer();
                      },
                    );
                  });
                }),
              ),
            ),
          ],
        ),
      ),
      body: Obx(() => panels[controller.currentTabIndex.value]),
    );
  }

  // --- DESKTOP LAYOUT (Permanent Sidebar + Topbar) ---
  Widget _buildDesktopLayout(
    BuildContext context,
    List<Widget> panels,
    List<Map<String, dynamic>> menuItems,
  ) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // Sidebar Panel
          Container(
            width: 250,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: AppTheme.border, width: 1),
              ),
            ),
            child: Column(
              children: [
                _buildDrawerHeader(context),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.s16),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return Obx(() {
                        final isSelected =
                            controller.currentTabIndex.value == index;
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppTheme.s12,
                            vertical: AppTheme.s4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.background
                                : Colors.transparent,
                            borderRadius: AppTheme.borderMedium,
                          ),
                          child: ListTile(
                            leading: Icon(
                              item['icon'] as IconData,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                              size: 20,
                            ),
                            title: Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.borderMedium,
                            ),
                            onTap: () => controller.switchTab(index),
                          ),
                        );
                      });
                    },
                  ),
                ),
                // Footer details
                Padding(
                  padding: const EdgeInsets.all(AppTheme.s16),
                  child: TextButton.icon(
                    onPressed: () => authController.logout(),
                    icon: const Icon(
                      Icons.logout,
                      color: AppTheme.error,
                      size: 18,
                    ),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppTheme.error, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Body Area
          Expanded(
            child: Column(
              children: [
                // Topbar
                Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.border, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.s32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(
                          menuItems[controller.currentTabIndex.value]['title']
                              as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () =>
                                Get.offAllNamed(AppRoutes.CUSTOMER_HOME),
                            icon: const Icon(
                              Icons.storefront_outlined,
                              size: 16,
                            ),
                            label: const Text(
                              'View Storefront',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.s24),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                authController.profile?.email ?? 'Admin User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                (authController.profile?.role ?? 'admin')
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Active panel
                Expanded(
                  child: Obx(() => panels[controller.currentTabIndex.value]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 70,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.bubble_chart_outlined, color: AppTheme.primary, size: 28),
          SizedBox(width: 12),
          Text(
            'AuraLuxe Admin',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- OVERVIEW TAB CONTENT (Common between all layouts) ---
  Widget _buildOverviewTab(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final padding = isDesktop
        ? const EdgeInsets.all(AppTheme.s32)
        : const EdgeInsets.all(AppTheme.s16);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadDashboardStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Cards Grid
                _buildKPIGrid(context),
                const SizedBox(height: AppTheme.s32),

                // Recent Orders List Table
                const Text(
                  'Recent Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.s16),
                _buildRecentOrdersTable(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildKPIGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    double childAspectRatio = 2.4;

    if (width >= 1024) {
      crossAxisCount = 4;
      childAspectRatio = 1.3;
    } else if (width >= 600) {
      crossAxisCount = 2;
      childAspectRatio = 1.6;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: AppTheme.s16,
      mainAxisSpacing: AppTheme.s16,
      children: [
        _buildKPICard(
          title: 'Total Sales Revenue',
          value: '\$${controller.totalSales.value.toStringAsFixed(2)}',
          subtitle: 'From delivered orders',
          icon: Icons.monetization_on_outlined,
          color: Colors.green,
        ),
        _buildKPICard(
          title: 'Total Orders volume',
          value: '${controller.totalOrdersCount.value}',
          subtitle: 'Across all statuses',
          icon: Icons.shopping_cart_outlined,
          color: Colors.blue,
        ),
        _buildKPICard(
          title: 'Total Products count',
          value: '${controller.totalProductsCount.value}',
          subtitle: 'Active in stock database',
          icon: Icons.inventory_2_outlined,
          color: Colors.orange,
        ),
        _buildKPICard(
          title: 'Registered Users',
          value: '${controller.totalUsersCount.value}',
          subtitle: 'Customers & administrative team',
          icon: Icons.people_outline,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: AppTheme.s8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.s4),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersTable(BuildContext context) {
    if (controller.recentOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.borderMedium,
          border: Border.all(color: AppTheme.border),
        ),
        alignment: Alignment.center,
        child: const Text(
          'No orders placed yet.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentOrders.length,
        separatorBuilder: (context, index) =>
            const Divider(color: AppTheme.border, height: 1),
        itemBuilder: (context, index) {
          final order = controller.recentOrders[index];
          final date = DateFormat('MMM dd, yyyy').format(order.createdAt);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.s20,
              vertical: AppTheme.s8,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.customerName} • $date',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
            ),
            onTap: () {
              // Switch to Orders panel
              controller.switchTab(3);
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'pending':
        bg = Colors.amber.withOpacity(0.12);
        fg = Colors.amber[800]!;
        break;
      case 'confirmed':
        bg = Colors.blue.withOpacity(0.12);
        fg = Colors.blue[800]!;
        break;
      case 'processing':
        bg = Colors.purple.withOpacity(0.12);
        fg = Colors.purple[800]!;
        break;
      case 'packed':
        bg = Colors.orange.withOpacity(0.12);
        fg = Colors.orange[800]!;
        break;
      case 'shipped':
        bg = Colors.teal.withOpacity(0.12);
        fg = Colors.teal[800]!;
        break;
      case 'delivered':
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green[800]!;
        break;
      case 'cancelled':
        bg = Colors.red.withOpacity(0.12);
        fg = Colors.red[800]!;
        break;
      default:
        bg = Colors.grey.withOpacity(0.12);
        fg = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Extension to add border on Container decoration easily
extension BorderExtension on Widget {
  Widget border(Border border) {
    return Container(
      decoration: BoxDecoration(border: border),
      child: this,
    );
  }
}
