import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import 'package:aauraluxe/app/modules/customer/home/views/home_view.dart';
import 'package:aauraluxe/app/modules/customer/home/views/widgets/chardike_product_card.dart';
import 'package:aauraluxe/app/modules/customer/cart/controllers/cart_controller.dart';
import 'package:aauraluxe/app/modules/auth/controllers/auth_controller.dart';
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
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.categories.length + 1,
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
                final category = controller.categories[index - 1];
                final isSelected =
                    controller.selectedCategoryId.value == category.id;
                return _buildSidebarCategoryItem(
                  category.name,
                  isSelected,
                  () => controller.selectCategory(category.id),
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
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
              fontSize: 14,
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
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
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final category = isAll ? null : controller.categories[index - 1];
            final title = isAll ? 'All' : category!.name;
            final categoryId = isAll ? '' : category!.id;
            final isSelected =
                controller.selectedCategoryId.value == categoryId;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(title),
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
          childAspectRatio: 0.6,
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
}
