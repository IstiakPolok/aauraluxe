import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import '../controllers/home_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import 'package:aauraluxe/app/modules/auth/controllers/auth_controller.dart';
import 'package:aauraluxe/app/routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Globally injected Cart & Auth controllers
    final CartController cartController = Get.put(CartController(), permanent: true);
    final AuthController authController = Get.put(AuthController(), permanent: true);

    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final paddingHorizontal = isDesktop ? MediaQuery.of(context).size.width * 0.1 : AppTheme.s16;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('A U R A L U X E', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: false,
        actions: [
          // Order tracking link
          IconButton(
            icon: const Icon(Icons.location_searching_outlined),
            tooltip: 'Track Order',
            onPressed: () => Get.toNamed(AppRoutes.ORDER_TRACKING),
          ),
          
          // Cart Badge
          Obx(() => Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    tooltip: 'Shopping Bag',
                    onPressed: () => Get.toNamed(AppRoutes.CART),
                  ),
                  if (!cartController.isEmpty)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${cartController.itemCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              )),
              
          // Profile/Login
          Obx(() => IconButton(
                icon: Icon(
                  authController.isAuthenticated 
                      ? (authController.profile?.isAdmin == true ? Icons.admin_panel_settings_outlined : Icons.person_outline)
                      : Icons.login_outlined,
                ),
                tooltip: authController.isAuthenticated ? 'Account / Dashboard' : 'Sign In',
                onPressed: () {
                  if (authController.isAuthenticated) {
                    if (authController.profile!.isAdmin || authController.profile!.isStaff) {
                      Get.toNamed(AppRoutes.ADMIN_DASHBOARD);
                    } else {
                      Get.toNamed(AppRoutes.ORDER_HISTORY);
                    }
                  } else {
                    Get.toNamed(AppRoutes.LOGIN);
                  }
                },
              )),
          const SizedBox(width: AppTheme.s8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadCategories();
          await controller.loadProducts();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: AppTheme.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Section
              _buildSearchBar(context),
              const SizedBox(height: AppTheme.s24),

              // Banners Carousel
              _buildBanners(context),
              const SizedBox(height: AppTheme.s32),

              // Categories Capsules
              const Text(
                'Shop by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: AppTheme.s16),
              _buildCategoriesList(context),
              const SizedBox(height: AppTheme.s32),

              // Featured Products Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.selectedCategoryId.value = '';
                      controller.loadProducts();
                    },
                    child: const Text('View All', style: TextStyle(color: AppTheme.accent)),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.s16),
              _buildProductsGrid(context, controller.featuredProducts),
              const SizedBox(height: AppTheme.s32),

              // New Arrivals List
              const Text(
                'New Arrivals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: AppTheme.s16),
              _buildProductsGrid(context, controller.newArrivals),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: TextField(
        onSubmitted: (value) => controller.applySearch(value),
        decoration: InputDecoration(
          hintText: 'Search products, collections, categories...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () {
                    controller.applySearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildBanners(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: controller.promoBanners.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppTheme.s4),
            decoration: BoxDecoration(
              borderRadius: AppTheme.borderLarge,
              image: DecorationImage(
                image: NetworkImage(controller.promoBanners[index]),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppTheme.borderLarge,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(AppTheme.s24),
              alignment: Alignment.bottomLeft,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summer Collection',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppTheme.s4),
                  Text(
                    'Up to 30% off on premium arrivals',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context) {
    return Obx(() {
      if (controller.isCategoriesLoading.value) {
        return const SizedBox(
          height: 40,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected = controller.selectedCategoryId.value == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: AppTheme.s8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                selectedColor: AppTheme.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderSmall,
                  side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
                ),
                onSelected: (_) => controller.selectCategory(category.id),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildProductsGrid(BuildContext context, List<Product> list) {
    return Obx(() {
      if (controller.isProductsLoading.value) {
        return const Center(child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ));
      }

      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textSecondary),
                const SizedBox(height: AppTheme.s16),
                const Text('No products found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: AppTheme.s8),
                const Text('Try resetting your search query or filters', style: TextStyle(color: AppTheme.textSecondary)),
                TextButton(
                  onPressed: () {
                    controller.selectedCategoryId.value = '';
                    controller.applySearch('');
                  },
                  child: const Text('Reset Filters'),
                ),
              ],
            ),
          ),
        );
      }

      final screenWidth = MediaQuery.of(context).size.width;
      int crossAxisCount = 2;
      if (screenWidth >= 1024) {
        crossAxisCount = 4;
      } else if (screenWidth >= 600) {
        crossAxisCount = 3;
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.72,
          crossAxisSpacing: AppTheme.s16,
          mainAxisSpacing: AppTheme.s16,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final product = list[index];
          return _buildProductCard(context, product);
        },
      );
    });
  }

  Widget _buildProductCard(BuildContext context, Product product) {
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
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Box
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMedium)),
                  image: DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: AppTheme.borderSmall,
                          ),
                          child: const Text(
                            'SALE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if (product.isOutOfStock)
                      Container(
                        color: Colors.white.withOpacity(0.6),
                        child: const Center(
                          child: Text(
                            'SOLD OUT',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content Box
            Padding(
              padding: const EdgeInsets.all(AppTheme.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 14),
                  ),
                  const SizedBox(height: AppTheme.s4),
                  
                  // Pricing Row
                  Row(
                    children: [
                      if (product.hasDiscount) ...[
                        Text(
                          '\$${product.discountPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 14),
                        ),
                        const SizedBox(width: AppTheme.s8),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 14),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
