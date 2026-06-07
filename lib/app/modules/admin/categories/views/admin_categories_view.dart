import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/admin_categories_controller.dart';
import 'package:aauraluxe/app/data/models/models.dart';

class AdminCategoriesView extends GetView<AdminCategoriesController> {
  const AdminCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject if not done
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final padding = isDesktop ? const EdgeInsets.all(AppTheme.s32) : const EdgeInsets.all(AppTheme.s16);

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: !isDesktop 
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              onPressed: () => _showCategoryDialog(context),
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
                  const Text('Manage Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Category'),
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

                if (controller.categories.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildCategoriesList(context);
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
          const Icon(Icons.category_outlined, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: AppTheme.s16),
          const Text('No categories found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Create folders to organize products in the storefront.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListView.separated(
        itemCount: controller.categories.length,
        separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
        itemBuilder: (context, index) {
          final cat = controller.categories[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s8),
            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: cat.description != null && cat.description!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(cat.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showCategoryDialog(context, cat),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                  onPressed: () => _showDeleteConfirmation(context, cat),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, [Category? category]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(text: category?.description ?? '');

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Category Name', hintText: 'e.g. Shoes'),
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description (Optional)', hintText: 'Collection of luxury items...'),
                ),
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
              controller.saveCategory(
                id: category?.id,
                name: nameController.text.trim(),
                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to permanently delete category "${category.name}"? Products inside will become uncategorized.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              controller.deleteCategory(category.id, category.name);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
