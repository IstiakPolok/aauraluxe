import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/admin_banners_controller.dart';
import 'package:aauraluxe/app/data/models/models.dart';

class AdminBannersView extends GetView<AdminBannersController> {
  const AdminBannersView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final padding = isDesktop ? const EdgeInsets.all(AppTheme.s32) : const EdgeInsets.all(AppTheme.s16);

    // Make sure controller is initialized
    Get.put(AdminBannersController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: !isDesktop 
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              onPressed: () => _showBannerDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manage Promo Banners', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ElevatedButton.icon(
                    onPressed: () => _showBannerDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Promo Banner'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.s24),
            ],

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.banners.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildBannersList(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.view_carousel_outlined, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: AppTheme.s16),
          const Text('No promo banners found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Add banners that link to your categories for promotions.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildBannersList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListView.separated(
        itemCount: controller.banners.length,
        separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
        itemBuilder: (context, index) {
          final banner = controller.banners[index];
          
          // Find target category name
          final category = controller.categories.firstWhereOrNull((c) => c.id == banner.categoryId);
          final targetText = category != null ? 'Redirects to: ${category.name}' : 'No Redirect (Static)';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s8),
            leading: ClipRRect(
              borderRadius: AppTheme.borderSmall,
              child: Image.network(
                banner.imageUrl,
                width: 100,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 50,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image_outlined, size: 20),
                ),
              ),
            ),
            title: Text(targetText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                banner.imageUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
              onPressed: () => _showDeleteConfirmation(context, banner),
            ),
          );
        },
      ),
    );
  }

  void _showBannerDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final urlController = TextEditingController();
    String? selectedCategoryId;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Promo Banner'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Banner Image URL',
                    hintText: 'https://example.com/banner.jpg',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (!v.trim().startsWith('http')) return 'Enter a valid URL';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Obx(() => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Target Category (Optional)',
                  ),
                  value: selectedCategoryId,
                  hint: const Text('Select category to navigate to'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('None (Static Banner)'),
                    ),
                    ...controller.categories.map((c) => DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.name),
                    )),
                  ],
                  onChanged: (val) {
                    selectedCategoryId = val;
                  },
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              controller.createBanner(
                imageUrl: urlController.text.trim(),
                categoryId: selectedCategoryId,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PromoBanner banner) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Promo Banner'),
        content: const Text('Are you sure you want to permanently delete this promo banner?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              controller.deleteBanner(banner.id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
