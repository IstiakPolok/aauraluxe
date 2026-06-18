import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/product_details_controller.dart';
import 'package:aauraluxe/app/routes/app_routes.dart';
import 'package:aauraluxe/app/modules/auth/controllers/auth_controller.dart';

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
              
              // Reviews Section
              _buildReviewsSection(context),

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
        const SizedBox(height: AppTheme.s8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              '(${product.reviewCount} Reviews)',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
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

  Widget _buildReviewsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final auth = Get.find<AuthController>();
                if (!auth.isAuthenticated) {
                  _showLoginDialog(context);
                } else {
                  _showReviewDialog(context);
                }
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Write a Review'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.s16),
        Obx(() {
          if (controller.isReviewsLoading.value && controller.reviews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.reviews.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(AppTheme.s24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: AppTheme.borderMedium,
              ),
              child: const Text(
                'No reviews yet. Be the first to review this product!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.reviews.length,
            separatorBuilder: (_, __) => const Divider(color: AppTheme.border, height: 32),
            itemBuilder: (context, index) {
              final review = controller.reviews[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review.userName ?? 'Verified Buyer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${review.createdAt.month}/${review.createdAt.day}/${review.createdAt.year}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  if (review.comment != null && review.comment!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      review.comment!,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4),
                    ),
                  ]
                ],
              );
            },
          );
        }),
      ],
    );
  }

  void _showLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final auth = Get.find<AuthController>();
    final isLoading = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Login Required'),
        content: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('You must be logged in to leave a review.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            if (isLoading.value) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ]
          ],
        )),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                Get.snackbar('Error', 'Please enter email and password');
                return;
              }
              isLoading.value = true;
              final success = await auth.login(
                emailController.text.trim(),
                passwordController.text,
                redirect: false, // Stay on this screen
              );
              isLoading.value = false;
              if (success) {
                Get.back(); // close login dialog
                // Now they can review
                _showReviewDialog(context);
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    int rating = 5;
    final commentController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Write a Review'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rate this product:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('Your thoughts:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'What did you like or dislike?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          }
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.submitReview(rating.toDouble(), commentController.text);
            },
            child: const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
