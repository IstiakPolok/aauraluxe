import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/product_details_controller.dart';
import 'package:aauraluxe/app/routes/app_routes.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final paddingHorizontal = isDesktop ? MediaQuery.of(context).size.width * 0.1 : AppTheme.s16;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Get.toNamed(AppRoutes.CART),
          ),
          const SizedBox(width: AppTheme.s8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final product = controller.product.value;
        if (product == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                const SizedBox(height: AppTheme.s16),
                const Text('Product not found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: AppTheme.s8),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.CUSTOMER_HOME),
                  child: const Text('Back to Shop'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: AppTheme.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                _buildDesktopLayout(context, product)
              else
                _buildMobileLayout(context, product),
              
              const SizedBox(height: AppTheme.s48),
              const Divider(color: AppTheme.border),
              const SizedBox(height: AppTheme.s32),
              
              // Related Products Section
              _buildRelatedProducts(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, dynamic product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gallery (55% width)
        Expanded(
          flex: 11,
          child: Column(
            children: [
              _buildImageSlider(context, product, 450.0),
              const SizedBox(height: AppTheme.s16),
              _buildThumbnails(context, product),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.s48),
        // Details (45% width)
        Expanded(
          flex: 9,
          child: _buildDetailsPanel(context, product),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, dynamic product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSlider(context, product, 300.0),
        const SizedBox(height: AppTheme.s16),
        _buildThumbnails(context, product),
        const SizedBox(height: AppTheme.s24),
        _buildDetailsPanel(context, product),
      ],
    );
  }

  Widget _buildImageSlider(BuildContext context, dynamic product, double height) {
    final images = product.imageUrls.isNotEmpty
        ? product.imageUrls
        : ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80'];

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppTheme.borderLarge,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: PageView.builder(
        controller: controller.pageController,
        itemCount: images.length,
        onPageChanged: (idx) => controller.activeImageIndex.value = idx,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: AppTheme.borderLarge,
            child: Image.network(
              images[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }

  Widget _buildThumbnails(BuildContext context, dynamic product) {
    final images = product.imageUrls.isNotEmpty
        ? product.imageUrls
        : ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80'];

    if (images.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.activeImageIndex.value == index;
            return GestureDetector(
              onTap: () => controller.updateActiveImage(index),
              child: Container(
                margin: const EdgeInsets.only(right: AppTheme.s8),
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: AppTheme.borderSmall,
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                    width: isSelected ? 2 : 1,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildDetailsPanel(BuildContext context, dynamic product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          product.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: AppTheme.s16),

        // Price Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (product.hasDiscount) ...[
              Text(
                '\$${product.discountPrice!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(width: AppTheme.s12),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: AppTheme.textSecondary,
                  fontSize: 18,
                ),
              ),
            ] else ...[
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ]
          ],
        ),
        const SizedBox(height: AppTheme.s24),

        // Stock Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s8),
          decoration: BoxDecoration(
            color: product.isOutOfStock ? AppTheme.error.withOpacity(0.08) : AppTheme.success.withOpacity(0.08),
            borderRadius: AppTheme.borderSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: product.isOutOfStock ? AppTheme.error : AppTheme.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.s8),
              Text(
                product.isOutOfStock 
                    ? 'Out of Stock' 
                    : '${product.stock} items in stock (Ready to ship)',
                style: TextStyle(
                  color: product.isOutOfStock ? AppTheme.error : AppTheme.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.s24),

        // Description
        const Text(
          'About this product',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: AppTheme.s8),
        Text(
          product.description ?? 'No description provided.',
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
        ),
        const SizedBox(height: AppTheme.s32),

        // Add to Bag Button
        ElevatedButton(
          onPressed: product.isOutOfStock ? null : () => controller.addToCart(),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
          ),
          child: Text(product.isOutOfStock ? 'Sold Out' : 'Add to Bag'),
        ),
      ],
    );
  }

  Widget _buildRelatedProducts(BuildContext context) {
    return Obx(() {
      if (controller.isRelatedLoading.value) {
        return const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.relatedProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You Might Also Like',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: AppTheme.s16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.relatedProducts.length,
              itemBuilder: (context, index) {
                final p = controller.relatedProducts[index];
                final image = p.imageUrls.isNotEmpty
                    ? p.imageUrls.first
                    : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80';

                return GestureDetector(
                  onTap: () {
                    // Navigate to details and trigger controller reload
                    Get.delete<ProductDetailsController>(); // reset instance for reload
                    Get.toNamed('${AppRoutes.PRODUCT_DETAILS}?id=${p.id}');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: AppTheme.s16),
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.borderMedium,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMedium)),
                            child: Image.network(
                              image,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.s12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: AppTheme.s4),
                              Text(
                                '\$${p.effectivePrice.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      );
    });
  }
}
