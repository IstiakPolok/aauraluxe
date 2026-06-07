import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/category_api.dart';
import 'package:aauraluxe/app/data/providers/activity_log_api.dart';

class AdminCategoriesController extends GetxController {
  final CategoryApi _categoryApi = Get.find<CategoryApi>();
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

  Future<void> saveCategory({String? id, required String name, String? description}) async {
    isLoading.value = true;
    try {
      final Category cat = Category(
        id: id ?? '',
        name: name,
        description: description,
        createdAt: DateTime.now(),
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
}
