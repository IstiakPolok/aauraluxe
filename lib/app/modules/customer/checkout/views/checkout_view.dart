import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import 'package:aauraluxe/app/modules/customer/checkout/controllers/checkout_controller.dart';
import 'package:aauraluxe/app/modules/customer/cart/controllers/cart_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final paddingHorizontal = isDesktop ? MediaQuery.of(context).size.width * 0.1 : AppTheme.s16;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: AppTheme.s24),
          child: isDesktop 
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form details (60% width)
                    Expanded(
                      flex: 6,
                      child: _buildCheckoutForm(context),
                    ),
                    const SizedBox(width: AppTheme.s32),
                    // Summary (40% width)
                    Expanded(
                      flex: 4,
                      child: _buildOrderSummaryCard(context, cartController),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildCheckoutForm(context),
                    const SizedBox(height: AppTheme.s24),
                    _buildOrderSummaryCard(context, cartController),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCheckoutForm(BuildContext context) {
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
            'Shipping Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.s24),

          // Name
          const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary, fontSize: 13)),
          const SizedBox(height: AppTheme.s8),
          TextFormField(
            controller: controller.nameController,
            decoration: const InputDecoration(hintText: 'John Doe'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your name';
              return null;
            },
          ),
          const SizedBox(height: AppTheme.s24),

          // Phone
          const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary, fontSize: 13)),
          const SizedBox(height: AppTheme.s8),
          TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+1 234 567 8900'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
              return null;
            },
          ),
          const SizedBox(height: AppTheme.s24),

          // Email
          const Text('Email Address (Optional)', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary, fontSize: 13)),
          const SizedBox(height: AppTheme.s8),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'john@example.com'),
            validator: (value) {
              if (value != null && value.isNotEmpty && !GetUtils.isEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.s24),

          // Address
          const Text('Shipping Address', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textPrimary, fontSize: 13)),
          const SizedBox(height: AppTheme.s8),
          TextFormField(
            controller: controller.addressController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Street Address, Apartment, City, Postal Code'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your shipping address';
              return null;
            },
          ),
          const SizedBox(height: AppTheme.s32),

          // Payment Method
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.s16),
          Obx(() => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: AppTheme.borderMedium,
                ),
                child: RadioListTile<String>(
                  title: const Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Pay with cash upon package arrival'),
                  value: 'COD',
                  groupValue: controller.paymentMethod.value,
                  activeColor: AppTheme.primary,
                  onChanged: (val) {
                    if (val != null) controller.paymentMethod.value = val;
                  },
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context, CartController cartController) {
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
            'Items in Order',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.s16),

          // Cart Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartController.cartItems.length,
            separatorBuilder: (context, index) => const Divider(color: AppTheme.border),
            itemBuilder: (context, index) {
              final item = cartController.cartItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.title}  x${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 16),

          // Cost Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: AppTheme.textSecondary)),
              Text('\$${cartController.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: TextStyle(color: AppTheme.textSecondary)),
              Text('Free', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text(
                '\$${cartController.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Place Order Button
          Obx(() => ElevatedButton(
                onPressed: controller.isProcessing.value ? null : () => controller.submitOrder(),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: controller.isProcessing.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Place Order (Cash on Delivery)'),
              )),
        ],
      ),
    );
  }
}
