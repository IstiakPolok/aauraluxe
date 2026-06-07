import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/product_api.dart';
import 'package:aauraluxe/app/data/providers/activity_log_api.dart';

class AdminProductsController extends GetxController {
  final ProductApi _productApi = Get.find<ProductApi>();
  final ActivityLogApi _activityLogApi = Get.put(ActivityLogApi());

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final list = await _productApi.getProducts(
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      products.value = list;
    } catch (e) {
      print('Admin products load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void search(String val) {
    searchQuery.value = val;
    loadProducts();
  }

  Future<void> saveProduct({
    String? id,
    required String title,
    String? description,
    required double price,
    double? discountPrice,
    String? categoryId,
    required int stock,
    required List<String> imageUrls,
  }) async {
    isLoading.value = true;
    try {
      final Product p = Product(
        id: id ?? '',
        title: title,
        description: description,
        price: price,
        discountPrice: discountPrice,
        categoryId: categoryId,
        stock: stock,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Product result;
      if (id == null) {
        // Create product
        result = await _productApi.createProduct(p);
        await _activityLogApi.logAction(
          action: 'created_product',
          entityType: 'product',
          entityId: result.id,
        );
        Get.snackbar('Success', 'Product "${result.title}" created successfully.', snackPosition: SnackPosition.BOTTOM);
      } else {
        // Update product
        result = await _productApi.updateProduct(id, p);
        await _activityLogApi.logAction(
          action: 'updated_product',
          entityType: 'product',
          entityId: id,
        );
        Get.snackbar('Success', 'Product "${result.title}" updated successfully.', snackPosition: SnackPosition.BOTTOM);
      }
      loadProducts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save product: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id, String title) async {
    isLoading.value = true;
    try {
      await _productApi.deleteProduct(id);
      await _activityLogApi.logAction(
        action: 'deleted_product',
        entityType: 'product',
        entityId: id,
      );
      Get.snackbar('Deleted', 'Product "$title" deleted successfully.', snackPosition: SnackPosition.BOTTOM);
      loadProducts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Handle local file selection mock and upload it
  Future<String> uploadImage(String name, List<int> bytes, String mime) async {
    return await _productApi.uploadProductImage(name, bytes, mime);
  }
}
