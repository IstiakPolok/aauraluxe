import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aauraluxe/app/data/models/models.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.effectivePrice * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product'] as Map<String, dynamic>),
        quantity: json['quantity'] as int? ?? 1,
      );
}

class CartController extends GetxController {
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  late SharedPreferences _prefs;

  double get subtotal => cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  double get total => subtotal; // Can add tax or shipping here
  int get itemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => cartItems.isEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  Future<void> _loadCart() async {
    _prefs = await SharedPreferences.getInstance();
    final data = _prefs.getString('shopping_cart');
    if (data != null) {
      try {
        final list = jsonDecode(data) as List;
        cartItems.value = list.map((json) => CartItem.fromJson(json as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Error loading cart data: $e');
      }
    }
  }

  Future<void> _saveCart() async {
    final list = cartItems.map((item) => item.toJson()).toList();
    await _prefs.setString('shopping_cart', jsonEncode(list));
  }

  void addProduct(Product product) {
    // Check if product is already in cart
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      // Validate stock
      if (cartItems[index].quantity < product.stock) {
        cartItems[index].quantity++;
        cartItems.refresh();
        Get.snackbar('Added', '${product.title} quantity increased in cart.', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Out of Stock', 'Cannot add more. Limit of ${product.stock} reached.', snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      // Add new
      if (product.stock > 0) {
        cartItems.add(CartItem(product: product, quantity: 1));
        Get.snackbar('Added', '${product.title} added to cart.', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Out of Stock', 'This product is out of stock.', snackPosition: SnackPosition.BOTTOM);
      }
    }
    _saveCart();
  }

  void decreaseQuantity(Product product) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
      } else {
        cartItems.removeAt(index);
      }
      _saveCart();
    }
  }

  void removeProduct(Product product) {
    cartItems.removeWhere((item) => item.product.id == product.id);
    _saveCart();
  }

  void clearCart() {
    cartItems.clear();
    _saveCart();
  }
}
