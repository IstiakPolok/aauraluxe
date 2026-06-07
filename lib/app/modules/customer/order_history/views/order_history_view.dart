import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/order_history_controller.dart';
import 'package:aauraluxe/app/modules/auth/controllers/auth_controller.dart';
import 'package:aauraluxe/app/routes/app_routes.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final paddingHorizontal = isDesktop ? MediaQuery.of(context).size.width * 0.15 : AppTheme.s16;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.error),
            tooltip: 'Sign Out',
            onPressed: () => authController.logout(),
          ),
          const SizedBox(width: AppTheme.s8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadOrderHistory(),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: AppTheme.s24),
            itemCount: controller.orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppTheme.s16),
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return _buildOrderCard(context, order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_outlined, size: 72, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.s24),
            const Text(
              'No Order History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: AppTheme.s8),
            const Text(
              'You have not placed any orders yet. Explore AuraLuxe products to find your first item!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.s32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.CUSTOMER_HOME),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(order.createdAt);
    final totalItems = order.items.fold(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #$order.id',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: AppTheme.s8),
          Text(
            'Ordered on: $formattedDate',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: AppTheme.s16),
          const Divider(color: AppTheme.border),
          const SizedBox(height: AppTheme.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalItems ${totalItems == 1 ? "item" : "items"}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.ORDER_TRACKING,
                    arguments: {
                      'orderId': order.id,
                      'phone': order.customerPhone,
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24, vertical: AppTheme.s12),
                ),
                child: const Text('Track Package'),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
