import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/admin_orders_controller.dart';

class AdminOrdersView extends GetView<AdminOrdersController> {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final padding = isDesktop ? const EdgeInsets.all(AppTheme.s32) : const EdgeInsets.all(AppTheme.s16);

    final List<String> statuses = [
      'all', 'pending', 'confirmed', 'processing', 'packed', 'shipped', 'delivered', 'cancelled'
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: padding,
        child: Column(
          children: [
            // Filter actions
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.borderMedium,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: TextField(
                      onChanged: (val) => controller.search(val),
                      decoration: const InputDecoration(
                        hintText: 'Search orders by customer name or phone...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.s16),

            // Horizontal status capsules
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: statuses.length,
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  return Obx(() {
                    final isSelected = controller.selectedStatus.value == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.s8),
                      child: ChoiceChip(
                        label: Text(status.toUpperCase()),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.borderSmall,
                          side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
                        ),
                        onSelected: (_) => controller.filterStatus(status),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: AppTheme.s24),

            // Orders list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.orders.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildOrdersList(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: AppTheme.s16),
          const Text('No orders found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Orders matching your filters will show up here.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListView.separated(
        itemCount: controller.orders.length,
        separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
        itemBuilder: (context, index) {
          final order = controller.orders[index];
          final date = DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt);

          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s8),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.customerName} • $date',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
              children: [
                Container(
                  color: AppTheme.background,
                  padding: const EdgeInsets.all(AppTheme.s24),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sub headers details
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shipping address
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('SHIPPING DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textSecondary)),
                                const SizedBox(height: 8),
                                Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('Phone: ${order.customerPhone}', style: const TextStyle(fontSize: 13)),
                                if (order.customerEmail != null) ...[
                                  const SizedBox(height: 2),
                                  Text('Email: ${order.customerEmail}', style: const TextStyle(fontSize: 13)),
                                ],
                                const SizedBox(height: 4),
                                Text(order.shippingAddress, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.s24),
                          // Actions
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('UPDATE STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textSecondary)),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: order.status.toLowerCase(),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: ['pending', 'confirmed', 'processing', 'packed', 'shipped', 'delivered', 'cancelled']
                                      .map((status) => DropdownMenuItem<String>(
                                            value: status,
                                            child: Text(status.toUpperCase(), style: const TextStyle(fontSize: 12)),
                                          ))
                                      .toList(),
                                  onChanged: (newStatus) {
                                    if (newStatus != null) {
                                      controller.updateStatus(order.id, newStatus);
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.s24),
                      const Divider(color: AppTheme.border),
                      const SizedBox(height: AppTheme.s16),

                      // Order items table
                      const Text('ORDER ITEMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 12),
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.items.length,
                        itemBuilder: (context, idx) {
                          final item = order.items[idx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.productTitle} x${item.quantity}', style: const TextStyle(fontSize: 13)),
                                Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
