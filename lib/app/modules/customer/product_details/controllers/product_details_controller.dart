import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/product_api.dart';
import 'package:aauraluxe/app/modules/customer/cart/controllers/cart_controller.dart';

class ProductDetailsController extends GetxController {
  final ProductApi _productApi = Get.put(ProductApi());
  final CartController _cartController = Get.find<CartController>();

  final Rxn<Product> product = Rxn<Product>();
  final RxList<Product> relatedProducts = <Product>[].obs;

  final RxInt activeImageIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRelatedLoading = false.obs;

  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    final productId = Get.parameters['id'];
    if (productId != null) {
      loadProduct(productId);
    }
  }

  Future<void> loadProduct(String id) async {
    isLoading.value = true;
    try {
      final p = await _productApi.getProductById(id);
      product.value = p;
      if (p != null) {
        activeImageIndex.value = 0;
        if (pageController.hasClients) {
          pageController.jumpToPage(0);
        }
        loadRelatedProducts(p);
      }
    } catch (e) {
      print('Failed to load product details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRelatedProducts(Product activeProduct) async {
    if (activeProduct.categoryId == null) return;
    isRelatedLoading.value = true;
    try {
      final list = await _productApi.getProducts(
        categoryId: activeProduct.categoryId,
      );
      // Filter out the active product itself
      relatedProducts.value = list
          .where((p) => p.id != activeProduct.id)
          .toList();
    } catch (e) {
      print('Failed to load related products: $e');
    } finally {
      isRelatedLoading.value = false;
    }
  }

  void updateActiveImage(int index) {
    if (activeImageIndex.value == index) return;
    activeImageIndex.value = index;
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void addToCart() {
    if (product.value != null) {
      _cartController.addProduct(product.value!);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
