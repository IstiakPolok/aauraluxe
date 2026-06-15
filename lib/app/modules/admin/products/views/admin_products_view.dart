import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/admin_products_controller.dart';
import '../../categories/controllers/admin_categories_controller.dart';
import 'package:aauraluxe/app/data/models/models.dart';

class AdminProductsView extends GetView<AdminProductsController> {
  const AdminProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controllers if not injected
    final AdminCategoriesController categoriesController = Get.find<AdminCategoriesController>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final padding = isDesktop ? const EdgeInsets.all(AppTheme.s32) : const EdgeInsets.all(AppTheme.s16);

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: !isDesktop 
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              onPressed: () => _showProductDialog(context, categoriesController),
              child: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: padding,
        child: Column(
          children: [
            // Header actions
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.borderMedium,
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: TextField(
                      onChanged: (val) => controller.search(val),
                      decoration: const InputDecoration(
                        hintText: 'Search products by title...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: AppTheme.s24),
                  ElevatedButton.icon(
                    onPressed: () => _showProductDialog(context, categoriesController),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ]
              ],
            ),
            const SizedBox(height: AppTheme.s24),

            // Products list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.products.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildProductsList(context, categoriesController);
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
          const Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: AppTheme.s16),
          const Text('No products available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Create your first item to build the shop database.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildProductsList(BuildContext context, AdminCategoriesController categoriesController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListView.separated(
        itemCount: controller.products.length,
        separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
        itemBuilder: (context, index) {
          final product = controller.products[index];
          final category = categoriesController.categories.firstWhereOrNull((c) => c.id == product.categoryId);
          final image = product.imageUrls.isNotEmpty 
              ? product.imageUrls.first 
              : 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s8),
            leading: ClipRRect(
              borderRadius: AppTheme.borderSmall,
              child: Image.network(image, width: 48, height: 48, fit: BoxFit.cover),
            ),
            title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      category?.name ?? 'Uncategorized',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: AppTheme.s12),
                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(
                      fontSize: 12,
                      color: product.stock <= 5 ? AppTheme.error : AppTheme.textSecondary,
                      fontWeight: product.stock <= 5 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${product.effectivePrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: AppTheme.s12),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showProductDialog(context, categoriesController, product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                  onPressed: () => _showDeleteConfirmation(context, product),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showProductDialog(BuildContext context, AdminCategoriesController categoriesController, [Product? product]) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: product?.title ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final discountController = TextEditingController(text: product?.discountPrice?.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '');
    final imageController = TextEditingController(text: product?.imageUrls.isNotEmpty == true ? product!.imageUrls.join(', ') : '');
    
    String? selectedCatId = product?.categoryId;
    if (selectedCatId == null && categoriesController.categories.isNotEmpty) {
      selectedCatId = categoriesController.categories.first.id;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(product == null ? 'Add New Product' : 'Edit Product'),
        content: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Product Title', hintText: 'e.g. Leather Bag'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description', hintText: 'About product...'),
                  ),
                  const SizedBox(height: 12),

                  // Price & Discount Price
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Price (\$)', hintText: '100.00'),
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Required';
                            if (double.tryParse(v!) == null) return 'Must be double';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: discountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Sale Price (\$)', hintText: 'Optional'),
                          validator: (v) {
                            if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                              return 'Must be double';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stock & Category dropdown
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Stock Qty', hintText: '50'),
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Required';
                            if (int.tryParse(v!) == null) return 'Must be integer';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCatId,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: categoriesController.categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat.id,
                              child: Text(cat.name, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            selectedCatId = val;
                          },
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                   // Image URL csv + upload button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Image URLs (comma separated)',
                            hintText: 'http://url1.jpg, http://url2.jpg',
                            helperText: 'Click upload to add local files to the list',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: IconButton(
                          icon: const Icon(Icons.upload_file, color: AppTheme.primary),
                          tooltip: 'Upload from device',
                          onPressed: () async {
                            final url = await controller.uploadImageFromDevice();
                            if (url != null) {
                              if (imageController.text.trim().isEmpty) {
                                imageController.text = url;
                              } else {
                                imageController.text = '${imageController.text.trim()}, $url';
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
              
              List<String> urls = [];
              if (imageController.text.trim().isNotEmpty) {
                urls = imageController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
              }

              controller.saveProduct(
                id: product?.id,
                title: titleController.text.trim(),
                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
                price: double.parse(priceController.text.trim()),
                discountPrice: discountController.text.trim().isEmpty ? null : double.parse(discountController.text.trim()),
                categoryId: selectedCatId,
                stock: int.parse(stockController.text.trim()),
                imageUrls: urls,
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to permanently delete "${product.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              controller.deleteProduct(product.id, product.title);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
