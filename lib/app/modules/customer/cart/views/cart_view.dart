import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/cart_controller.dart';
import 'package:aauraluxe/app/routes/app_routes.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final paddingHorizontal = isDesktop ? MediaQuery.of(context).size.width * 0.1 : AppTheme.s16;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Shopping Bag'),
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isEmpty) {
          return _buildEmptyCart(context);
        }

        return isDesktop 
            ? _buildDesktopLayout(context, paddingHorizontal)
            : _buildMobileLayout(context, paddingHorizontal);
      }),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 72, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.s24),
            const Text(
              'Your Shopping Bag is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: AppTheme.s8),
            const Text(
              'Explore our collection and add premium styles to your bag.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.s32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.CUSTOMER_HOME),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, double paddingHorizontal) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: AppTheme.s24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items list (60% width)
          Expanded(
            flex: 6,
            child: _buildCartItemsList(context),
          ),
          const SizedBox(width: AppTheme.s32),
          // Summary card (40% width)
          Expanded(
            flex: 4,
            child: _buildSummaryCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, double paddingHorizontal) {
    return Column(
      children: [
        // Items list (scrollable)
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: AppTheme.s16),
            child: _buildCartItemsList(context),
          ),
        ),
        // Summary & Checkout (anchored bottom)
        _buildBottomMobileSummary(context),
      ],
    );
  }

  Widget _buildCartItemsList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.cartItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppTheme.s16),
      itemBuilder: (context, index) {
        final item = controller.cartItems[index];
        final product = item.product;
        final image = product.imageUrls.isNotEmpty
            ? product.imageUrls.first
            : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80';

        return Container(
          padding: const EdgeInsets.all(AppTheme.s16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.borderMedium,
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: AppTheme.borderSmall,
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.s16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: AppTheme.s4),
                    Text(
                      '\$${product.effectivePrice.toStringAsFixed(2)} each',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: AppTheme.s12),
                    
                    // Quantity Stepper
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.border),
                            borderRadius: AppTheme.borderSmall,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: () => controller.decreaseQuantity(product),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () => controller.addProduct(product),
                              ),
                            ],
                          ),
                        ),
                        
                        // Total Price for this item
                        Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.s8),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                onPressed: () => controller.removeProduct(product),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderLarge,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.s24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: AppTheme.textSecondary)),
              Text('\$${controller.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppTheme.s12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: TextStyle(color: AppTheme.textSecondary)),
              Text('Free', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppTheme.s16),
          const Divider(color: AppTheme.border),
          const SizedBox(height: AppTheme.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text(
                '\$${controller.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.s32),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.CHECKOUT),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomMobileSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppTheme.border, width: 1)),
        boxShadow: AppTheme.softShadow,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    Text(
                      '\$${controller.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.CHECKOUT),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.s32, vertical: AppTheme.s16),
                  ),
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
