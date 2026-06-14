import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/routes/app_routes.dart';
import '../../../cart/controllers/cart_controller.dart';

class ChardikeProductCard extends StatelessWidget {
  final Product product;
  final int? rank;
  
  const ChardikeProductCard({
    Key? key,
    required this.product,
    this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final image = product.imageUrls.isNotEmpty
        ? product.imageUrls.first
        : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80';

    return GestureDetector(
      onTap: () => Get.toNamed('${AppRoutes.PRODUCT_DETAILS}?id=${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.borderMedium,
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusMedium),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (rank != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          rank.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: AppTheme.borderSmall,
                        ),
                        child: Text(
                          '${((product.price - product.discountPrice!) / product.price * 100).toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.hasDiscount) ...[
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '\$${product.discountPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.accent, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${product.soldCount} Sold',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final cart = Get.find<CartController>();
                          cart.addProduct(product);
                          Get.snackbar(
                            'Added to Bag',
                            '${product.title} added',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.primary,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(AppTheme.s16),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Add To Cart', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
