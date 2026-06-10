class AppRoutes {
  static const String LOGIN = '/login';
  
  // Customer Routes
  static const String CUSTOMER_HOME = '/';
  static const String PRODUCT_DETAILS = '/product'; // Parameterized like /product?id=xxx
  static const String CATEGORY_PRODUCTS = '/category'; // Parameterized like /category?id=xxx
  static const String CART = '/cart';
  static const String CHECKOUT = '/checkout';
  static const String ORDER_TRACKING = '/track';
  static const String ORDER_HISTORY = '/history';
  
  // Admin Routes
  static const String ADMIN_DASHBOARD = '/admin';
  static const String ADMIN_PRODUCTS = '/admin/products';
  static const String ADMIN_ORDERS = '/admin/orders';
  static const String ADMIN_CATEGORIES = '/admin/categories';
  static const String ADMIN_LOGS = '/admin/logs';
}
