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
            title: Row(
              children: [
                Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (cat.isSpecial) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(int.parse(cat.specialColor!.replaceFirst('#', '0xff'))).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(int.parse(cat.specialColor!.replaceFirst('#', '0xff')))),
                    ),
                    child: Text(
                      'SPECIAL',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(int.parse(cat.specialColor!.replaceFirst('#', '0xff'))),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
    
    bool isSpecial = category?.isSpecial ?? false;
    String specialColor = category?.specialColor ?? '#E91E63';

    final presetColors = [
      {'name': 'Pink (Deals)', 'hex': '#E91E63'},
      {'name': 'Emerald (New)', 'hex': '#00A86B'},
      {'name': 'Teal (Combos)', 'hex': '#008080'},
      {'name': 'Purple (Luxury)', 'hex': '#673AB7'},
      {'name': 'Amber (Offers)', 'hex': '#FFC107'},
      {'name': 'Indigo (Premium)', 'hex': '#3F51B5'},
    ];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
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
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Description (Optional)', hintText: 'Collection of luxury items...'),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Special Category (Deals, Combos)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Highlighted with custom styling', style: TextStyle(fontSize: 12)),
                      contentPadding: EdgeInsets.zero,
                      value: isSpecial,
                      activeColor: AppTheme.primary,
                      onChanged: (val) {
                        setState(() {
                          isSpecial = val;
                        });
                      },
                    ),
                    if (isSpecial) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Special Theme Color'),
                        value: specialColor,
                        items: presetColors.map((color) {
                          return DropdownMenuItem<String>(
                            value: color['hex'],
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(color['hex']!.replaceFirst('#', '0xff'))),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(color['name']!),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              specialColor = val;
                            });
                          }
                        },
                      ),
                    ],
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
                    isSpecial: isSpecial,
                    specialColor: specialColor,
                  );
                  Get.back();
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
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
