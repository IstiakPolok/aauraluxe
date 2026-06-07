import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/order_tracking_controller.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final paddingHorizontal = isDesktop ? MediaQuery.of(context).size.width * 0.15 : AppTheme.s16;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Track Order'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: AppTheme.s24),
        child: Column(
          children: [
            // Lookup Form
            _buildSearchForm(context),
            const SizedBox(height: AppTheme.s24),

            // Results Section
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (!controller.hasSearched.value) {
                return _buildIntroCard();
              }

              final order = controller.trackedOrder.value;
              if (order == null) {
                return _buildNotFoundCard();
              }

              return _buildOrderDetails(context, order);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Track your package status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: AppTheme.s16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.idController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Order ID (e.g. 12345)',
                      prefixIcon: Icon(Icons.receipt_long_outlined, size: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Required';
                      if (int.tryParse(value.trim()) == null) return 'Must be numeric';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.s12),
                Expanded(
                  child: TextFormField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.s16),
            ElevatedButton(
              onPressed: () => controller.searchOrder(),
              child: const Text('Track Order'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      child: const Column(
        children: [
          Icon(Icons.local_shipping_outlined, size: 64, color: AppTheme.textSecondary),
          SizedBox(height: AppTheme.s16),
          Text(
            'Keep an eye on your shipment',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: AppTheme.s8),
          Text(
            'Enter your Order ID and the phone number provided at checkout to track real-time delivery status.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      child: const Column(
        children: [
          Icon(Icons.search_off_outlined, size: 64, color: AppTheme.error),
          SizedBox(height: AppTheme.s16),
          Text(
            'Order Not Found',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.error),
          ),
          SizedBox(height: AppTheme.s8),
          Text(
            'We couldn\'t find any order matching this Order ID and phone number. Double-check your details and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, dynamic order) {
    final formattedDate = DateFormat('MMMM dd, yyyy - hh:mm a').format(order.createdAt);
    
    return Column(
      children: [
        // Header Status Card
        Container(
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
                    'Order #${order.id}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: AppTheme.s8),
              Text(
                'Placed on: $formattedDate',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: AppTheme.s12),
              Text(
                'Total Amount: \$${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.s24),

        // Stepper Status Timeline
        if (order.status.toLowerCase() == 'cancelled')
          Container(
            padding: const EdgeInsets.all(AppTheme.s24),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.08),
              borderRadius: AppTheme.borderMedium,
              border: Border.all(color: AppTheme.error.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.cancel_outlined, color: AppTheme.error, size: 28),
                SizedBox(width: AppTheme.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This order has been cancelled',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error, fontSize: 15),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'If you did not request this, please contact support.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          _buildStatusTimeline(context),
        
        const SizedBox(height: AppTheme.s24),

        // Shipping Details & Items List
        Container(
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
              const Text(
                'Shipping Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: AppTheme.s12),
              Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppTheme.s4),
              Text('Phone: ${order.customerPhone}'),
              if (order.customerEmail != null) ...[
                const SizedBox(height: AppTheme.s4),
                Text('Email: ${order.customerEmail}'),
              ],
              const SizedBox(height: AppTheme.s8),
              Text('Address: ${order.shippingAddress}', style: const TextStyle(color: AppTheme.textSecondary)),
              
              const SizedBox(height: AppTheme.s24),
              const Divider(color: AppTheme.border),
              const SizedBox(height: AppTheme.s24),

              const Text(
                'Items Ordered',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: AppTheme.s12),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (context, index) => const Divider(color: AppTheme.border),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productTitle} x${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildStatusTimeline(BuildContext context) {
    final currentStep = controller.statusStep;
    final List<Map<String, String>> steps = [
      {'title': 'Pending', 'desc': 'Order Received'},
      {'title': 'Confirmed', 'desc': 'Accepted by Vendor'},
      {'title': 'Processing', 'desc': 'Preparing Items'},
      {'title': 'Packed', 'desc': 'Ready to Hand Over'},
      {'title': 'Shipped', 'desc': 'In Transit'},
      {'title': 'Delivered', 'desc': 'Arrived'},
    ];

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
          const Text(
            'Shipment Timeline',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.s24),
          Column(
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isCompleted = index <= currentStep;
              final isLast = index == steps.length - 1;
              final color = isCompleted ? AppTheme.success : AppTheme.divider;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Node
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: color, width: isCompleted ? 6 : 2),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: index < currentStep ? AppTheme.success : AppTheme.divider,
                        ),
                    ],
                  ),
                  const SizedBox(width: AppTheme.s16),
                  
                  // Text details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title']!,
                            style: TextStyle(
                              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                              color: isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['desc']!,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
