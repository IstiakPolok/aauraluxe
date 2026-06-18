import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/product_api.dart';
import 'package:aauraluxe/app/data/providers/category_api.dart';
import 'package:aauraluxe/app/data/providers/promo_banner_api.dart';

class HomeController extends GetxController {
  final ProductApi _productApi = Get.put(ProductApi());
  final CategoryApi _categoryApi = Get.put(CategoryApi());
  final PromoBannerApi _bannerApi = Get.put(PromoBannerApi());

  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<PromoBanner> promoBanners = <PromoBanner>[].obs;
  
  final RxString selectedCategoryId = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'newest'.obs;
  
  final RxBool isProductsLoading = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxBool isBannersLoading = false.obs;

  // Carousel active page and page controller properties
  final PageController promoPageController = PageController();
  final RxInt currentPromoIndex = 0.obs;
  Timer? _promoTimer;

  // Search overlay properties
  final RxList<Product> searchResults = <Product>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool showSearchDropdown = false.obs;
  Timer? _searchDebounce;

  // Static fallback banners
  final List<PromoBanner> _fallbackBanners = [
    PromoBanner(
      id: 'mock1',
      imageUrl: 'https://images.unsplash.com/photo-1596462502278-27bf85033e5a?w=1200&q=80',
      createdAt: DateTime.now(),
    ),
    PromoBanner(
      id: 'mock2',
      imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=1200&q=80',
      createdAt: DateTime.now(),
    ),
    PromoBanner(
      id: 'mock3',
      imageUrl: 'https://images.unsplash.com/photo-1571781926291-c477eb31f24e?w=1200&q=80',
      createdAt: DateTime.now(),
    ),
  ];

  // Mock Mega Deals Banners
  final List<String> megaDealsBanners = [
    'https://images.unsplash.com/photo-1612817288484-6f916006741a?w=400&q=80', // Beauty product
    'https://images.unsplash.com/photo-1522337660859-02fbefca4702?w=400&q=80', // Creams
    'https://images.unsplash.com/photo-1617897903246-719242758050?w=400&q=80', // Make up
    'https://images.unsplash.com/photo-1599305090598-fe179d501227?w=400&q=80', // Oils
  ];

  // Hot Menu Links
  final List<Map<String, dynamic>> hotMenuLinks = [
    {'title': 'All Offers', 'icon': Icons.local_offer_outlined, 'route': '/all-offer'},
    {'title': 'New Arrival', 'icon': Icons.new_releases_outlined, 'route': '/new-arrival'},
    {'title': 'Top Review', 'icon': Icons.star_outline, 'route': '/top-review'},
    {'title': 'Brands', 'icon': Icons.branding_watermark_outlined, 'route': '/brands'},
  ];

  final ScrollController newProductsScrollController = ScrollController();
  final ScrollController topSellingScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadPromoBanners();
    loadCategories();
    loadProducts();
  }

  Future<void> loadPromoBanners() async {
    isBannersLoading.value = true;
    try {
      final list = await _bannerApi.getBanners();
      if (list.isEmpty) {
        promoBanners.value = _fallbackBanners;
      } else {
        promoBanners.value = list;
      }
    } catch (e) {
      print('Failed to load promo banners from DB, falling back to mocks: $e');
      promoBanners.value = _fallbackBanners;
    } finally {
      isBannersLoading.value = false;
      _startPromoTimer();
    }
  }

  void _startPromoTimer() {
    _promoTimer?.cancel();
    if (promoBanners.isEmpty) return;
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (promoBanners.isEmpty) return;
      int nextPage = currentPromoIndex.value + 1;
      if (nextPage >= promoBanners.length) {
        nextPage = 0;
      }
      currentPromoIndex.value = nextPage;
      if (promoPageController.hasClients) {
        promoPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
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

  void onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (query.trim().isEmpty) {
      searchResults.clear();
      showSearchDropdown.value = false;
      return;
    }

    showSearchDropdown.value = true;
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      isSearching.value = true;
      try {
        final results = await _productApi.getProducts(searchQuery: query);
        searchResults.value = results;
      } catch (e) {
        print('Search failed: $e');
      } finally {
        isSearching.value = false;
      }
    });
  }

  void clearSearch() {
    searchResults.clear();
    showSearchDropdown.value = false;
  }

  @override
  void onClose() {
    _promoTimer?.cancel();
    promoPageController.dispose();
    _searchDebounce?.cancel();
    newProductsScrollController.dispose();
    topSellingScrollController.dispose();
    super.onClose();
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

  List<Product> get bestSellingProducts {
    // For demonstration, simulating best selling by sorting stock lowest to highest (items selling fast)
    final sorted = List<Product>.from(products);
    sorted.sort((a, b) => a.stock.compareTo(b.stock));
    if (sorted.length <= 6) return sorted;
    return sorted.sublist(0, 6);
  }
}
