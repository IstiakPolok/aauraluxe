import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import 'package:aauraluxe/app/modules/customer/home/views/home_view.dart';
import 'package:aauraluxe/app/modules/customer/home/views/widgets/chardike_product_card.dart';
import 'package:aauraluxe/app/modules/customer/cart/controllers/cart_controller.dart';
import 'package:aauraluxe/app/modules/auth/controllers/auth_controller.dart';
import 'package:aauraluxe/app/data/models/category.dart';
import '../controllers/category_products_controller.dart';

class CategoryProductsView extends GetView<CategoryProductsController> {
  const CategoryProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final AuthController authController = Get.find<AuthController>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    const homeView = HomeView();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: isDesktop
          ? null
          : homeView.buildMobileAppBar(context, cartController, authController),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isDesktop)
              homeView.buildDesktopHeader(
                context,
                cartController,
                authController,
              ),
            if (isDesktop) homeView.buildDesktopNavBar(context),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? MediaQuery.of(context).size.width * 0.1
                    : AppTheme.s16,
                vertical: AppTheme.s24,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desktop Sidebar
                  if (isDesktop) ...[
                    SizedBox(width: 250, child: _buildDesktopSidebar(context)),
                    const SizedBox(width: AppTheme.s32),
                  ],

                  // Main Product Listing Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header (Title + Breadcrumbs & Sort Options)
                        _buildCategoryHeader(context, isDesktop),
                        const SizedBox(height: AppTheme.s24),

                        // Special Category Featured Banner
                        Obx(() {
                          final category = controller.currentCategory;
                          if (category != null &&
                              _isSpecialCategory(category)) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppTheme.s24,
                              ),
                              child: _buildSpecialCategoryBanner(
                                context,
                                category,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),

                        // Mobile Category horizontal list
                        if (!isDesktop) ...[
                          _buildMobileCategoryChips(context),
                          const SizedBox(height: AppTheme.s16),
                        ],

                        // Products Grid
                        _buildProductsGrid(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            homeView.buildFooterSection(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(AppTheme.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.s16),
          Obx(() {
            if (controller.isCategoriesLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final normalCats = controller.categories
                .where((c) => !_isSpecialCategory(c))
                .toList();
            final specialCats = controller.categories
                .where((c) => _isSpecialCategory(c))
                .toList();
            final sortedCategories = [...normalCats, ...specialCats];

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedCategories.length + 1,
              separatorBuilder: (_, __) =>
                  const Divider(height: 24, color: AppTheme.border),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isAllSelected =
                      controller.selectedCategoryId.value.isEmpty;
                  return _buildSidebarCategoryItem(
                    'All Products',
                    isAllSelected,
                    () => controller.selectCategory(''),
                  );
                }
                final category = sortedCategories[index - 1];
                final isSelected =
                    controller.selectedCategoryId.value == category.id;
                final isSpecial = _isSpecialCategory(category);
                final specColor = isSpecial
                    ? _parseHexColor(category.specialColor)
                    : null;

                return _buildSidebarCategoryItem(
                  category.name,
                  isSelected,
                  () => controller.selectCategory(category.id),
                  isSpecial: isSpecial,
                  specialColor: specColor,
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSidebarCategoryItem(
    String title,
    bool isSelected,
    VoidCallback onTap, {
    bool isSpecial = false,
    Color? specialColor,
  }) {
    final textColor = isSpecial
        ? (isSelected
              ? (specialColor ?? AppTheme.primary)
              : (specialColor ?? AppTheme.primary).withOpacity(0.7))
        : (isSelected ? AppTheme.primary : AppTheme.textPrimary);

    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isSpecial) ...[
                Icon(Icons.star, size: 14, color: specialColor ?? Colors.amber),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected || isSpecial
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: textColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: isSelected
                ? (isSpecial
                      ? (specialColor ?? AppTheme.primary)
                      : AppTheme.primary)
                : AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, bool isDesktop) {
    return Obx(() {
      final category = controller.currentCategory;
      final title = category != null ? category.name : 'All Products';

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Home > Category > $title',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          _buildSortDropdown(),
        ],
      );
    });
  }

  Widget _buildSortDropdown() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.sortBy.value,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppTheme.textSecondary,
            ),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.updateSort(newValue);
              }
            },
            items: const [
              DropdownMenuItem(value: 'newest', child: Text('Sort by: Newest')),
              DropdownMenuItem(
                value: 'price_asc',
                child: Text('Sort by: Price (Low to High)'),
              ),
              DropdownMenuItem(
                value: 'price_desc',
                child: Text('Sort by: Price (High to Low)'),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMobileCategoryChips(BuildContext context) {
    return Obx(() {
      if (controller.isCategoriesLoading.value) return const SizedBox.shrink();

      final normalCats = controller.categories.where((c) => !_isSpecialCategory(c)).toList();
      final specialCats = controller.categories.where((c) => _isSpecialCategory(c)).toList();
      final sortedCategories = [...normalCats, ...specialCats];

      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: sortedCategories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final category = isAll ? null : sortedCategories[index - 1];
            final title = isAll ? 'All' : category!.name;
            final categoryId = isAll ? '' : category!.id;
            final isSelected =
                controller.selectedCategoryId.value == categoryId;
            final isSpecial = category != null && _isSpecialCategory(category);
            final specColor = isSpecial ? _parseHexColor(category.specialColor) : AppTheme.primary;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSpecial) ...[
                      Icon(
                        Icons.star,
                        size: 12,
                        color: isSelected ? Colors.white : specColor,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(title),
                  ],
                ),
                selected: isSelected,
                selectedColor: specColor,
                backgroundColor: isSpecial ? specColor.withOpacity(0.08) : Colors.white,
                labelStyle: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : (isSpecial ? specColor : AppTheme.textPrimary),
                  fontWeight: isSelected || isSpecial ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderSmall,
                  side: BorderSide(
                    color: isSelected 
                        ? specColor 
                        : (isSpecial ? specColor.withOpacity(0.3) : AppTheme.border),
                  ),
                ),
                onSelected: (_) => controller.selectCategory(categoryId),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildProductsGrid(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        );
      }

      if (controller.products.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Text(
              'No products found in this category.',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ),
        );
      }

      final screenWidth = MediaQuery.of(context).size.width;
      int crossAxisCount = screenWidth >= 1024
          ? 4
          : (screenWidth >= 600 ? 3 : 2);

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.54,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          return ChardikeProductCard(product: controller.products[index]);
        },
      );
    });
  }

  bool _isSpecialCategory(Category category) {
    if (category.isSpecial) return true;
    final name = category.name.toLowerCase();
    return name.contains('premium') ||
        name.contains('gift box') ||
        name.contains('offers') ||
        name.contains('special');
  }

  Color _parseHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return AppTheme.primary;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  Widget _buildSpecialCategoryBanner(BuildContext context, Category category) {
    final baseColor = _parseHexColor(category.specialColor);
    final descriptionText =
        category.description ??
        (category.name.toLowerCase().contains('premium')
            ? 'Indulge in our collection of ultra-premium and luxurious products.'
            : category.name.toLowerCase().contains('gift box')
            ? 'Curated gift hampers and sets perfect for your loved ones.'
            : category.name.toLowerCase().contains('offers')
            ? 'Super discounts and hot deals handpicked just for you.'
            : 'Exclusive collections featured especially for you.');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppTheme.borderLarge,
        gradient: LinearGradient(
          colors: [
            baseColor.withOpacity(0.85),
            baseColor.withOpacity(0.55),
            AppTheme.textPrimary.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppTheme.borderLarge,
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.s24,
                vertical: AppTheme.s32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'FEATURED CATEGORY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.s16),
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppTheme.s8),
                  Text(
                    descriptionText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
