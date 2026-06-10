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
import 'widgets/chardike_product_card.dart';
import 'widgets/search_dropdown_field.dart';

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

    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: isDesktop
          ? null
          : buildMobileAppBar(context, cartController, authController),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadPromoBanners();
          await controller.loadCategories();
          await controller.loadProducts();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isDesktop)
                buildDesktopHeader(context, cartController, authController),
              if (isDesktop) buildDesktopNavBar(context),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? MediaQuery.of(context).size.width * 0.1
                      : AppTheme.s16,
                  vertical: AppTheme.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isDesktop) buildMobileSearchBar(context),
                    if (!isDesktop) const SizedBox(height: AppTheme.s16),

                    _buildHeroSlider(context),
                    const SizedBox(height: AppTheme.s32),

                    _buildMegaDeals(context, isDesktop),
                    const SizedBox(height: AppTheme.s32),

                    _buildHotMenu(context, isDesktop),
                    const SizedBox(height: AppTheme.s32),

                    _buildSectionHeader('Weekly Ranking', onSeeAll: () {}),
                    const SizedBox(height: AppTheme.s16),
                    _buildWeeklyRankingList(context),

                    const SizedBox(height: AppTheme.s32),

                    _buildSectionHeader(
                      'All Products',
                      onSeeAll: () {
                        Get.toNamed(AppRoutes.CATEGORY_PRODUCTS);
                      },
                    ),
                    const SizedBox(height: AppTheme.s16),
                    if (!isDesktop) _buildCategoriesList(context),
                    if (!isDesktop) const SizedBox(height: AppTheme.s16),
                    _buildProductsGrid(context, controller.products),
                  ],
                ),
              ),
              buildFooterSection(isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildMobileAppBar(
    BuildContext context,
    CartController cartController,
    AuthController authController,
  ) {
    return AppBar(
      title: GestureDetector(
        onTap: () => Get.offAllNamed(AppRoutes.CUSTOMER_HOME),
        child: Image.asset(
          'assets/logo.png',
          height: 32,
          errorBuilder: (_, __, ___) => const Text(
            'AuraLuxe',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.location_searching_outlined),
          onPressed: () => Get.toNamed(AppRoutes.ORDER_TRACKING),
        ),
        Obx(
          () => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => Get.toNamed(AppRoutes.CART),
              ),
              if (!cartController.isEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartController.itemCount}',
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
                  ? Icons.person_outline
                  : Icons.login_outlined,
            ),
            onPressed: () {
              if (authController.isAuthenticated) {
                Get.toNamed(
                  authController.profile?.isAdmin == true
                      ? AppRoutes.ADMIN_DASHBOARD
                      : AppRoutes.ORDER_HISTORY,
                );
              } else {
                Get.toNamed(AppRoutes.LOGIN);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildMobileSearchBar(BuildContext context) {
    return const SearchDropdownField(isMobile: true);
  }

  Widget buildDesktopHeader(
    BuildContext context,
    CartController cartController,
    AuthController authController,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.offAllNamed(AppRoutes.CUSTOMER_HOME),
                child: Image.asset(
                  'assets/logo.png',
                  height: 40,
                  errorBuilder: (_, __, ___) => const Text(
                    'AuraLuxe',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              const SizedBox(width: 400, child: SearchDropdownField()),
            ],
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.local_offer, color: AppTheme.accent),
                label: const Text(
                  'Deals',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(width: 16),
              Obx(
                () => TextButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.CART),
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppTheme.primary,
                  ),
                  label: Text(
                    'Cart (${cartController.itemCount})',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Obx(
                () => TextButton.icon(
                  onPressed: () {
                    if (authController.isAuthenticated) {
                      Get.toNamed(
                        authController.profile?.isAdmin == true
                            ? AppRoutes.ADMIN_DASHBOARD
                            : AppRoutes.ORDER_HISTORY,
                      );
                    } else {
                      Get.toNamed(AppRoutes.LOGIN);
                    }
                  },
                  icon: const Icon(
                    Icons.person_outline,
                    color: AppTheme.primary,
                  ),
                  label: Text(
                    authController.isAuthenticated ? 'Account' : 'Sign In',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDesktopNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    navLink(
                      'All Categories',
                      '',
                      isSelected: controller.selectedCategoryId.value.isEmpty,
                    ),
                    ...controller.categories.where((c) => !c.isSpecial).map(
                      (c) => navLink(
                        c.name,
                        c.id,
                        isSelected: controller.selectedCategoryId.value == c.id,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                ...controller.categories.where((c) => c.isSpecial).map((c) {
                  final hexColor = c.specialColor ?? '#E91E63';
                  final color = Color(int.parse(hexColor.replaceFirst('#', '0xff')));
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: specialNavLink(c.name, color, () {
                      Get.toNamed('${AppRoutes.CATEGORY_PRODUCTS}?id=${c.id}');
                    }),
                  );
                }),
                if (controller.categories.where((c) => c.isSpecial).isEmpty) ...[
                  specialNavLink('Buy One Get One', AppTheme.accent, () {}),
                  const SizedBox(width: 16),
                  specialNavLink('Brands', Colors.pink, () {}),
                  const SizedBox(width: 16),
                  specialNavLink('Blog', Colors.teal, () {}),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget navLink(String title, String categoryId, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: GestureDetector(
        onTap: () =>
            Get.toNamed('${AppRoutes.CATEGORY_PRODUCTS}?id=$categoryId'),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget specialNavLink(String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSlider(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width >= 1024 ? 400 : 200,
      child: Obx(() {
        if (controller.isBannersLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.promoBanners.isEmpty) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            // Slide viewer
            ClipRRect(
              borderRadius: AppTheme.borderLarge,
              child: PageView.builder(
                controller: controller.promoPageController,
                onPageChanged: (index) => controller.currentPromoIndex.value = index,
                itemCount: controller.promoBanners.length,
                itemBuilder: (context, index) {
                  final banner = controller.promoBanners[index];
                  return GestureDetector(
                    onTap: () {
                      if (banner.categoryId != null && banner.categoryId!.isNotEmpty) {
                        Get.toNamed('${AppRoutes.CATEGORY_PRODUCTS}?id=${banner.categoryId}');
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppTheme.s4),
                      decoration: BoxDecoration(
                        borderRadius: AppTheme.borderLarge,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                        image: DecorationImage(
                          image: NetworkImage(banner.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Dot Indicators overlay
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(controller.promoBanners.length, (index) {
                  final isSelected = controller.currentPromoIndex.value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      ],
                    ),
                  );
                }),
              ),
            ),

            // Left arrow
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppTheme.textPrimary),
                    onPressed: () {
                      int prevPage = controller.currentPromoIndex.value - 1;
                      if (prevPage < 0) prevPage = controller.promoBanners.length - 1;
                      controller.promoPageController.animateToPage(
                        prevPage,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),

            // Right arrow
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textPrimary),
                    onPressed: () {
                      int nextPage = controller.currentPromoIndex.value + 1;
                      if (nextPage >= controller.promoBanners.length) nextPage = 0;
                      controller.promoPageController.animateToPage(
                        nextPage,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMegaDeals(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mega Deals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.s16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 4 : 2,
            childAspectRatio: 2.0,
            crossAxisSpacing: AppTheme.s16,
            mainAxisSpacing: AppTheme.s16,
          ),
          itemCount: controller.megaDealsBanners.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: AppTheme.borderMedium,
                image: DecorationImage(
                  image: NetworkImage(controller.megaDealsBanners[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHotMenu(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: controller.hotMenuLinks.map((menu) {
        return Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.borderMedium,
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Icon(menu['icon'], color: AppTheme.primary, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    menu['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See All',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyRankingList(BuildContext context) {
    return Obx(() {
      if (controller.isProductsLoading.value) {
        return const SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final items = controller.featuredProducts;
      return SizedBox(
        height: 320,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              width: 180,
              margin: const EdgeInsets.only(right: 16),
              child: ChardikeProductCard(
                product: items[index],
                rank: index + 1,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCategoriesList(BuildContext context) {
    return Obx(() {
      if (controller.isCategoriesLoading.value) return const SizedBox.shrink();
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            final isSelected =
                controller.selectedCategoryId.value == category.id;
            
            Color chipColor = AppTheme.primary;
            Color textColor = isSelected ? Colors.white : AppTheme.textPrimary;
            Color bgColor = Colors.white;
            Color borderColor = AppTheme.border;

            if (category.isSpecial) {
              final hexColor = category.specialColor ?? '#E91E63';
              final baseColor = Color(int.parse(hexColor.replaceFirst('#', '0xff')));
              chipColor = baseColor;
              if (isSelected) {
                bgColor = baseColor;
                textColor = Colors.white;
                borderColor = baseColor;
              } else {
                bgColor = baseColor.withOpacity(0.1);
                textColor = baseColor;
                borderColor = baseColor;
              }
            } else {
              if (isSelected) {
                bgColor = AppTheme.primary;
                textColor = Colors.white;
                borderColor = AppTheme.primary;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                selectedColor: chipColor,
                backgroundColor: bgColor,
                labelStyle: TextStyle(
                  color: textColor,
                  fontWeight: (isSelected || category.isSpecial) ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderSmall,
                  side: BorderSide(
                    color: borderColor,
                  ),
                ),
                onSelected: (_) => Get.toNamed(
                  '${AppRoutes.CATEGORY_PRODUCTS}?id=${category.id}',
                ),
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
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (list.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('No products found'),
          ),
        );
      }

      final screenWidth = MediaQuery.of(context).size.width;
      int crossAxisCount = screenWidth >= 1024
          ? 5
          : (screenWidth >= 600 ? 3 : 2);

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return ChardikeProductCard(product: list[index]);
        },
      );
    });
  }

  Widget buildFooterSection(bool isDesktop) {
    return Container(
      color: const Color(0xFF212121),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 48,
      ),
      margin: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AuraLuxe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your authentic beauty products, cosmetics and skincare shop.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Icon(Icons.facebook, color: Colors.white),
                        SizedBox(width: 16),
                        Icon(Icons.camera_alt, color: Colors.white),
                        SizedBox(width: 16),
                        Icon(Icons.play_circle_fill, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ABOUT US',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Privacy Policy\nTerms & Conditions\nPoint Policy\nReturn Policy',
                      style: TextStyle(color: Colors.white70, height: 2),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CONTACT US',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '📍 Head Office: 123 Beauty Ave',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '✉️ info@aauraluxe.com',
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '📞 +1-800-123-4567',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'DOWNLOAD APP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Icon(Icons.android, color: Colors.white, size: 40),
                    Icon(Icons.apple, color: Colors.white, size: 40),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            '© 2026 AuraLuxe. All Rights Reserved.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
