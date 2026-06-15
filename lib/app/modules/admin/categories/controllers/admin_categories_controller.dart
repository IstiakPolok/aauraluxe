import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/category_api.dart';
import 'package:aauraluxe/app/data/providers/product_api.dart';
import 'package:aauraluxe/app/data/providers/activity_log_api.dart';

class AdminCategoriesController extends GetxController {
  final CategoryApi _categoryApi = Get.put(CategoryApi());
  final ProductApi _productApi = Get.put(ProductApi());
  final ActivityLogApi _activityLogApi = Get.put(ActivityLogApi());

  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      final list = await _categoryApi.getCategories();
      categories.value = list;
    } catch (e) {
      print('Admin categories load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveCategory({
    String? id,
    required String name,
    String? description,
    String? imageUrl,
    bool isSpecial = false,
    String? specialColor,
  }) async {
    isLoading.value = true;
    try {
      final String? combinedDescription = (imageUrl != null && imageUrl.trim().isNotEmpty)
          ? '${description ?? ''} || ${imageUrl.trim()}'
          : description;

      final Category cat = Category(
        id: id ?? '',
        name: name,
        description: combinedDescription,
        createdAt: DateTime.now(),
        isSpecial: isSpecial,
        specialColor: specialColor ?? '#E91E63',
      );

      Category result;
      if (id == null) {
        result = await _categoryApi.createCategory(cat);
        await _activityLogApi.logAction(
          action: 'created_category',
          entityType: 'category',
          entityId: result.id,
        );
        Get.snackbar('Success', 'Category "${result.name}" created successfully.', snackPosition: SnackPosition.BOTTOM);
      } else {
        result = await _categoryApi.updateCategory(id, cat);
        await _activityLogApi.logAction(
          action: 'updated_category',
          entityType: 'category',
          entityId: id,
        );
        Get.snackbar('Success', 'Category "${result.name}" updated successfully.', snackPosition: SnackPosition.BOTTOM);
      }
      loadCategories();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save category: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(String id, String name) async {
    isLoading.value = true;
    try {
      await _categoryApi.deleteCategory(id);
      await _activityLogApi.logAction(
        action: 'deleted_category',
        entityType: 'category',
        entityId: id,
      );
      Get.snackbar('Deleted', 'Category "$name" deleted successfully.', snackPosition: SnackPosition.BOTTOM);
      loadCategories();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Pick category image from device and upload it to storage
  Future<String?> pickAndUploadImage() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes != null) {
          final fileName = 'category_${DateTime.now().millisecondsSinceEpoch}_${file.name}';
          final mime = file.extension == 'png' ? 'image/png' : 'image/jpeg';
          isLoading.value = true;
          final uploadedUrl = await _productApi.uploadProductImage(fileName, bytes, mime);
          return uploadedUrl;
        }
      }
    } catch (e) {
      Get.snackbar('Upload Error', 'Failed to upload category picture: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
    return null;
  }
}
