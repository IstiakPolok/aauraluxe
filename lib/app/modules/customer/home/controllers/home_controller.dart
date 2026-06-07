import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/product_api.dart';
import 'package:aauraluxe/app/data/providers/category_api.dart';

class HomeController extends GetxController {
  final ProductApi _productApi = Get.put(ProductApi());
  final CategoryApi _categoryApi = Get.put(CategoryApi());

  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  
  final RxString selectedCategoryId = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'newest'.obs;
  
  final RxBool isProductsLoading = false.obs;
  final RxBool isCategoriesLoading = false.obs;

  // Promos / Banner Images
  final List<String> promoBanners = [
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200&q=80', // Elegant boutique
    'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=1200&q=80', // Modern garments
    'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200&q=80', // Luxury fashion
  ];

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadProducts();
  }

  Future<void> loadCategories() async {
    isCategoriesLoading.value = true;
    try {
      final list = await _categoryApi.getCategories();
      categories.value = list;
    } catch (e) {
      print('Failed to load categories: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> loadProducts() async {
    isProductsLoading.value = true;
    try {
      final list = await _productApi.getProducts(
        categoryId: selectedCategoryId.value.isEmpty ? null : selectedCategoryId.value,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
        sortBy: sortBy.value,
      );
      products.value = list;
    } catch (e) {
      print('Failed to load products: $e');
    } finally {
      isProductsLoading.value = false;
    }
  }

  void selectCategory(String categoryId) {
    if (selectedCategoryId.value == categoryId) {
      // Toggle off
      selectedCategoryId.value = '';
    } else {
      selectedCategoryId.value = categoryId;
    }
    loadProducts();
  }

  void applySearch(String query) {
    searchQuery.value = query;
    loadProducts();
  }

  void updateSort(String option) {
    sortBy.value = option;
    loadProducts();
  }

  // Subsections
  List<Product> get featuredProducts {
    // Return first 4 items as featured
    if (products.length <= 4) return products;
    return products.sublist(0, 4);
  }

  List<Product> get newArrivals {
    // Sort products by date and return first 6 items
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (sorted.length <= 6) return sorted;
    return sorted.sublist(0, 6);
  }
}
