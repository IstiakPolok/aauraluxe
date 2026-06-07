import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final CartController cartController = Get.put(
      CartController(),
      permanent: true,
    );
    final AuthController authController = Get.put(
      AuthController(),
      permanent: true,
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrTablet = screenWidth >= 800;

    if (isDesktopOrTablet) {
      return _buildDesktopLayout(context, cartController, authController);
    } else {
      return _buildMobileLayout(context, cartController, authController);
    }
  }

  // --- MOBILE LAYOUT (PRESERVED) ---

  Widget _buildMobileLayout(
    BuildContext context,
    CartController cartController,
    AuthController authController,
  ) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final paddingHorizontal = isDesktop
        ? MediaQuery.of(context).size.width * 0.1
        : AppTheme.s16;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'A U R A L U X E',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_searching_outlined),
            tooltip: 'Track Order',
            onPressed: () => Get.toNamed(AppRoutes.ORDER_TRACKING),
          ),
          Obx(
            () => Stack(
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
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
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
            ),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                authController.isAuthenticated
                    ? (authController.profile?.isAdmin == true
                          ? Icons.admin_panel_settings_outlined
                          : Icons.person_outline)
                    : Icons.login_outlined,
              ),
              tooltip: authController.isAuthenticated
                  ? 'Account / Dashboard'
                  : 'Sign In',
              onPressed: () {
                if (authController.isAuthenticated) {
                  if (authController.profile!.isAdmin ||
                      authController.profile!.isStaff) {
                    Get.toNamed(AppRoutes.ADMIN_DASHBOARD);
                  } else {
                    Get.toNamed(AppRoutes.ORDER_HISTORY);
                  }
                } else {
                  Get.toNamed(AppRoutes.LOGIN);
                }
              },
            ),
          ),
          const SizedBox(width: AppTheme.s8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadCategories();
          await controller.loadProducts();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: AppTheme.s24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              const SizedBox(height: AppTheme.s24),
              _buildBanners(context),
              const SizedBox(height: AppTheme.s32),
              const Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.s16),
              _buildCategoriesList(context),
              const SizedBox(height: AppTheme.s32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Featured Products',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.selectedCategoryId.value = '';
                      controller.loadProducts();
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(color: AppTheme.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.s16),
              _buildProductsGrid(context, controller.featuredProducts),
              const SizedBox(height: AppTheme.s32),
              const Text(
                'New Arrivals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
            final isSelected =
                controller.selectedCategoryId.value == category.id;
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
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                  ),
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
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: AppTheme.s16),
                const Text(
                  'No products found',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: AppTheme.s8),
                const Text(
                  'Try resetting your search query or filters',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
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
          return _buildMobileProductCard(context, product);
        },
      );
    });
  }

  Widget _buildMobileProductCard(BuildContext context, Product product) {
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
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMedium),
                  ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: AppTheme.borderSmall,
                          ),
                          child: const Text(
                            'SALE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
            Padding(
              padding: const EdgeInsets.all(AppTheme.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppTheme.s4),
                  Row(
                    children: [
                      if (product.hasDiscount) ...[
                        Text(
                          '\$${product.discountPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            fontSize: 14,
                          ),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DESKTOP/TABLET LAYOUT COMPONENTS (ELECTRO STYLE) ---

  Widget _buildDesktopLayout(
    BuildContext context,
    CartController cartController,
    AuthController authController,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopBar(context, authController),
            _buildDesktopHeader(context, cartController, authController),
            _buildDesktopNavBar(context),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.08,
                vertical: AppTheme.s32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromoCollections(context),
                  const SizedBox(height: AppTheme.s48),
                  _buildDesktopSection(
                    context,
                    title: 'NEW PRODUCTS',
                    productsList: controller.newArrivals,
                    cartController: cartController,
                    scrollController: controller.newProductsScrollController,
                  ),
                  const SizedBox(height: AppTheme.s48),
                  _buildHotDealBanner(context),
                  const SizedBox(height: AppTheme.s48),
                  _buildDesktopSection(
                    context,
                    title: 'TOP SELLING',
                    productsList: controller.featuredProducts,
                    cartController: cartController,
                    scrollController: controller.topSellingScrollController,
                  ),
                  const SizedBox(height: AppTheme.s48),
                  _buildBottomGridLists(context),
                ],
              ),
            ),
            _buildNewsletterSection(),
            _buildFooterSection(authController),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AuthController authController) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 900) {
      return Container(
        color: const Color(0xFF1E1F29),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '+021-95-51-84',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            GestureDetector(
              onTap: () {
                if (authController.isAuthenticated) {
                  Get.toNamed(
                    authController.profile!.isAdmin ||
                            authController.profile!.isStaff
                        ? AppRoutes.ADMIN_DASHBOARD
                        : AppRoutes.ORDER_HISTORY,
                  );
                } else {
                  Get.toNamed(AppRoutes.LOGIN);
                }
              },
              child: Text(
                authController.isAuthenticated ? 'My Account' : 'Login',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFF1E1F29),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                color: Color(0xFFD10024),
                size: 14,
              ),
              const SizedBox(width: 6),
              const Text(
                '+021-95-51-84',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.email_outlined,
                color: Color(0xFFD10024),
                size: 14,
              ),
              const SizedBox(width: 6),
              const Text(
                'support@aauraluxe.com',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFD10024),
                size: 14,
              ),
              const SizedBox(width: 6),
              const Text(
                '1734 Stonecoal Road',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '\$ USD',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  if (authController.isAuthenticated) {
                    if (authController.profile!.isAdmin ||
                        authController.profile!.isStaff) {
                      Get.toNamed(AppRoutes.ADMIN_DASHBOARD);
                    } else {
                      Get.toNamed(AppRoutes.ORDER_HISTORY);
                    }
                  } else {
                    Get.toNamed(AppRoutes.LOGIN);
                  }
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      color: Color(0xFFD10024),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      authController.isAuthenticated
                          ? 'My Account'
                          : 'Login / Signup',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(
    BuildContext context,
    CartController cartController,
    AuthController authController,
  ) {
    return Container(
      color: const Color(0xFF15161D),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.08,
        vertical: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              controller.selectedCategoryId.value = '';
              controller.applySearch('');
            },
            child: Row(
              children: [
                Text(
                  'AuraLuxe',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '.',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD10024),
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Obx(() {
                      final categories = controller.categories;
                      final selectedId = controller.selectedCategoryId.value;
                      final selectedName = selectedId.isEmpty
                          ? 'All Categories'
                          : (categories
                                    .firstWhereOrNull((c) => c.id == selectedId)
                                    ?.name ??
                                'Category');
                      return DropdownButton<String>(
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: Colors.black87,
                        ),
                        hint: Text(
                          selectedName,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text(
                              'All Categories',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          ...categories.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectCategory(val);
                          }
                        },
                      );
                    }),
                  ),
                  const VerticalDivider(
                    width: 1,
                    color: Colors.grey,
                    indent: 8,
                    endIndent: 8,
                  ),
                  Expanded(
                    child: TextField(
                      onSubmitted: (val) => controller.applySearch(val),
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search here...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 12, bottom: 10),
                        filled: false,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Trigger search
                    },
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD10024),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _buildHeaderBadgeButton(
                icon: Icons.favorite_border,
                label: 'Your Wishlist',
                badgeCount: '2',
                onTap: () {
                  Get.snackbar(
                    'Wishlist',
                    'You have 2 items in your wishlist.',
                  );
                },
              ),
              const SizedBox(width: 24),
              Obx(
                () => _buildHeaderBadgeButton(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Your Cart',
                  badgeCount: '${cartController.itemCount}',
                  onTap: () => Get.toNamed(AppRoutes.CART),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadgeButton({
    required IconData icon,
    required String label,
    required String badgeCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD10024),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    badgeCount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavBar(BuildContext context) {
    final marginHorizontal = MediaQuery.of(context).size.width * 0.08;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE4E7ED), width: 1)),
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: marginHorizontal, vertical: 12),
      child: Obx(() {
        final categories = controller.categories;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildNavCategoryLink(
                'Home',
                '',
                controller.selectedCategoryId.value.isEmpty,
              ),
              _buildNavCategoryLink('Hot Deals', 'hot-deals', false),
              _buildNavCategoryLink('Categories', 'all-categories', false),
              ...categories.map((c) {
                return _buildNavCategoryLink(
                  c.name,
                  c.id,
                  controller.selectedCategoryId.value == c.id,
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNavCategoryLink(
    String label,
    String categoryId,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        if (categoryId == 'hot-deals' || categoryId == 'all-categories') {
          // Do nothing or filter
        } else {
          controller.selectCategory(categoryId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFD10024), width: 2),
                )
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? const Color(0xFFD10024) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCollections(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final List<String> promoUrls = [
      'https://images.unsplash.com/photo-1496181130204-755241524eab?w=600&q=80',
      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600&q=80',
    ];
    final List<String> promoNames = [
      'Laptop Collection',
      'Accessories Collection',
      'Cameras Collection',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        childAspectRatio: 1.7,
        crossAxisSpacing: AppTheme.s24,
        mainAxisSpacing: AppTheme.s24,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: AppTheme.borderSmall,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                top: 10,
                width: isDesktop ? screenWidth * 0.14 : screenWidth * 0.35,
                child: Image.network(promoUrls[index], fit: BoxFit.contain),
              ),
              Positioned.fill(
                child: ClipPath(
                  clipper: PromoCardClipper(),
                  child: Container(
                    color: const Color(0xFFD10024).withOpacity(0.9),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                top: 0,
                bottom: 0,
                width: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promoNames[index].split(' ').first,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      promoNames[index].split(' ').skip(1).join(' '),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        // Apply filter
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SHOP NOW',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFFD10024),
                              size: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopSection(
    BuildContext context, {
    required String title,
    required List<Product> productsList,
    required CartController cartController,
    required ScrollController scrollController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF15161D),
                letterSpacing: -0.5,
              ),
            ),
            Row(
              children: [
                Obx(() {
                  final categories = controller.categories;
                  return Row(
                    children: [
                      _buildSectionTab(
                        'Laptops',
                        controller.selectedCategoryId.value.isEmpty,
                        () {
                          controller.selectCategory('');
                        },
                      ),
                      ...categories.take(4).map((c) {
                        final isSelected =
                            controller.selectedCategoryId.value == c.id;
                        return _buildSectionTab(c.name, isSelected, () {
                          controller.selectCategory(c.id);
                        });
                      }),
                    ],
                  );
                }),
                const SizedBox(width: 16),
                _buildCircleArrowButton(Icons.chevron_left, () {
                  _scrollList(scrollController, true);
                }),
                const SizedBox(width: 8),
                _buildCircleArrowButton(Icons.chevron_right, () {
                  _scrollList(scrollController, false);
                }),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppTheme.s24),
        Obx(() {
          if (controller.isProductsLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(color: Color(0xFFD10024)),
              ),
            );
          }
          if (productsList.isEmpty) {
            return Container(
              height: 380,
              alignment: Alignment.center,
              child: const Text(
                'No products available under this collection.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return SizedBox(
            height: 440,
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: productsList.length,
              itemBuilder: (context, index) {
                final product = productsList[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  child: _buildDesktopProductCard(
                    context,
                    product,
                    cartController,
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionTab(String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFD10024), width: 2),
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFD10024) : Colors.black54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCircleArrowButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE4E7ED)),
        ),
        child: Icon(icon, color: Colors.black87, size: 18),
      ),
    );
  }

  void _scrollList(ScrollController scrollController, bool left) {
    if (!scrollController.hasClients) return;
    final double offset = scrollController.offset;
    final double target = left ? offset - 300 : offset + 300;
    scrollController.animateTo(
      target.clamp(0.0, scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDesktopProductCard(
    BuildContext context,
    Product product,
    CartController cartController,
  ) {
    final image = product.imageUrls.isNotEmpty
        ? product.imageUrls.first
        : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderSmall,
        border: Border.all(color: const Color(0xFFE4E7ED), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(image, fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      if (product.hasDiscount) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: const Color(0xFFD10024),
                          child: Text(
                            '-${((product.price - product.discountPrice!) / product.price * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.black,
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'CATEGORY',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF15161D),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (product.hasDiscount) ...[
                      Text(
                        '\$${product.discountPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD10024),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD10024),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: Color(0xFFD10024), size: 14),
                    Icon(Icons.star, color: Color(0xFFD10024), size: 14),
                    Icon(Icons.star, color: Color(0xFFD10024), size: 14),
                    Icon(Icons.star, color: Color(0xFFD10024), size: 14),
                    Icon(Icons.star, color: Color(0xFFD10024), size: 14),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSmallActionIcon(Icons.favorite_border, () {
                      Get.snackbar(
                        'Wishlist',
                        '"${product.title}" added to your wishlist.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF15161D),
                        colorText: Colors.white,
                      );
                    }),
                    const SizedBox(width: 12),
                    _buildSmallActionIcon(Icons.loop, () {
                      Get.snackbar(
                        'Compare',
                        'Product added to comparison list.',
                      );
                    }),
                    const SizedBox(width: 12),
                    _buildSmallActionIcon(Icons.remove_red_eye_outlined, () {
                      Get.toNamed(
                        '${AppRoutes.PRODUCT_DETAILS}?id=${product.id}',
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (!product.isOutOfStock) {
                cartController.addProduct(product);
              } else {
                Get.snackbar('Out of Stock', 'This product is out of stock.');
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFD10024),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusSmall),
                  bottomRight: Radius.circular(AppTheme.radiusSmall),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    product.isOutOfStock ? 'OUT OF STOCK' : 'ADD TO CART',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, color: const Color(0xFF15161D), size: 16),
    );
  }

  Widget _buildHotDealBanner(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F3F3),
        border: Border(
          top: BorderSide(color: Color(0xFFE4E7ED), width: 1),
          bottom: BorderSide(color: Color(0xFFE4E7ED), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isDesktop)
            Expanded(
              child: Image.network(
                'https://images.unsplash.com/photo-1496181130204-755241524eab?w=600&q=80',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const CountdownTimerWidget(),
                const SizedBox(height: 20),
                const Text(
                  'HOT DEAL THIS WEEK',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 0.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'NEW COLLECTION UP TO 50% OFF',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to hot deals or load discount products
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD10024),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'SHOP NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isDesktop)
            Expanded(
              child: Image.network(
                'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomGridLists(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 3 : 1,
      childAspectRatio: 1.6,
      crossAxisSpacing: AppTheme.s24,
      mainAxisSpacing: AppTheme.s24,
      children: [
        _buildCompactListColumn(
          'TOP SELLING',
          controller.featuredProducts.take(3).toList(),
        ),
        _buildCompactListColumn(
          'NEW ARRIVALS',
          controller.newArrivals.take(3).toList(),
        ),
        _buildCompactListColumn(
          'EXCLUSIVE OFFERS',
          controller.featuredProducts.skip(1).take(3).toList(),
        ),
      ],
    );
  }

  Widget _buildCompactListColumn(String title, List<Product> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF15161D),
              ),
            ),
            Row(
              children: [
                _buildCircleArrowButton(Icons.chevron_left, () {}),
                const SizedBox(width: 4),
                _buildCircleArrowButton(Icons.chevron_right, () {}),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(width: 50, height: 2, color: const Color(0xFFD10024)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final product = list[index];
              final img = product.imageUrls.isNotEmpty
                  ? product.imageUrls.first
                  : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE4E7ED)),
                        borderRadius: AppTheme.borderSmall,
                      ),
                      child: Image.network(img, fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CATEGORY',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.title.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFF15161D),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '\$${product.effectivePrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFD10024),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (product.hasDiscount) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsletterSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail_outline, size: 24, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Sign Up for the ',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                'NEWSLETTER',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 360,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE4E7ED)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter Your Email',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 10),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.snackbar('Newsletter', 'Thank you for subscribing!');
                },
                child: Container(
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD10024),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  alignment: Alignment.center,
                  child: Row(
                    children: const [
                      Icon(Icons.email_outlined, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Subscribe',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.chat_bubble_outline),
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.camera_alt_outlined),
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.alternate_email),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE4E7ED)),
      ),
      child: Icon(icon, size: 16, color: Colors.black87),
    );
  }

  Widget _buildFooterSection(AuthController authController) {
    return Column(
      children: [
        Container(height: 4, color: const Color(0xFFD10024)),
        Container(
          color: const Color(0xFF15161D),
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 24,
                runSpacing: 32,
                children: [
                  _buildFooterColumn('ABOUT US', [
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut.',
                    '1734 Stonecoal Road',
                    '+021-95-51-84',
                    'support@aauraluxe.com',
                  ]),
                  _buildFooterColumn('CATEGORIES', [
                    'Laptops',
                    'Smartphones',
                    'Cameras',
                    'Accessories',
                  ]),
                  _buildFooterColumn('INFORMATION', [
                    'About Us',
                    'Contact Us',
                    'Privacy Policy',
                    'Orders and Returns',
                    'Terms & Conditions',
                  ]),
                  _buildFooterColumn('SERVICE', [
                    authController.isAuthenticated
                        ? 'My Account'
                        : 'Login / Signup',
                    'View Cart',
                    'Track My Order',
                    'Help',
                  ]),
                ],
              ),
              const SizedBox(height: 48),
              const Divider(color: Colors.white10),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPaymentBadge('VISA'),
                  const SizedBox(width: 8),
                  _buildPaymentBadge('MC'),
                  const SizedBox(width: 8),
                  _buildPaymentBadge('PAYPAL'),
                  const SizedBox(width: 8),
                  _buildPaymentBadge('AMEX'),
                  const SizedBox(width: 8),
                  _buildPaymentBadge('DISCOVER'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Copyright ©2026 All rights reserved | This template is made with love.',
                style: TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterColumn(String title, List<String> links) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...links.map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                link,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PromoCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width * 0.75, 0);
    path.lineTo(size.width * 0.52, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CountdownTimerWidget extends StatefulWidget {
  const CountdownTimerWidget({super.key});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  int _days = 2;
  int _hours = 10;
  int _minutes = 34;
  int _seconds = 60;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _seconds = 59;
            if (_minutes > 0) {
              _minutes--;
            } else {
              _minutes = 59;
              if (_hours > 0) {
                _hours--;
              } else {
                _hours = 23;
                if (_days > 0) {
                  _days--;
                } else {
                  _days = 2;
                  _hours = 10;
                  _minutes = 34;
                  _seconds = 60;
                }
              }
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimerCircle('$_days', 'DAYS'),
        const SizedBox(width: 12),
        _buildTimerCircle('$_hours', 'HOURS'),
        const SizedBox(width: 12),
        _buildTimerCircle('$_minutes', 'MINS'),
        const SizedBox(width: 12),
        _buildTimerCircle('$_seconds', 'SECS'),
      ],
    );
  }

  Widget _buildTimerCircle(String value, String label) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFD10024),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
