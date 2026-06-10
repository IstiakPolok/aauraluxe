import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/product_api.dart';
import 'package:aauraluxe/app/data/providers/category_api.dart';

class CategoryProductsController extends GetxController {
  final ProductApi _productApi = Get.put(ProductApi());
  final CategoryApi _categoryApi = Get.put(CategoryApi());

  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;

  final RxString selectedCategoryId = ''.obs;
  final RxString sortBy = 'newest'.obs;

  final RxBool isLoading = false.obs;
  final RxBool isCategoriesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get category ID from query params or arguments
    final catId = Get.parameters['id'] ?? Get.arguments?.toString() ?? '';
    selectedCategoryId.value = catId;
    
    loadCategories();
    loadProducts();
  }

  Future<void> loadCategories() async {
    isCategoriesLoading.value = true;
    try {
      final list = await _categoryApi.getCategories();
      categories.value = list;
    } catch (e) {
      print('Failed to load categories in CategoryProductsController: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final list = await _productApi.getProducts(
        categoryId: selectedCategoryId.value.isEmpty ? null : selectedCategoryId.value,
        sortBy: sortBy.value,
      );
      products.value = list;
    } catch (e) {
      print('Failed to load products in CategoryProductsController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
    // Update the URL query params without reloading the page context entirely
    Get.parameters['id'] = categoryId;
    loadProducts();
  }

  void updateSort(String option) {
    sortBy.value = option;
    loadProducts();
  }

  Category? get currentCategory {
    if (selectedCategoryId.value.isEmpty) return null;
    return categories.firstWhereOrNull((c) => c.id == selectedCategoryId.value);
  }
}
