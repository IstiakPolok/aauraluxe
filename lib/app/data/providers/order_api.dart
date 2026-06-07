import 'dart:convert';
import 'package:get/get.dart';
import '../models/models.dart';
import 'api_client.dart';

class OrderApi extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Place a new order
  Future<Order> placeOrder(Order order, List<OrderItem> items) async {
    try {
      // Step 1: Create the parent order
      final orderData = order.toJson();
      orderData.remove('id'); // DB serial auto-generates order ID
      
      final orderResponse = await _apiClient.post(
        '/orders',
        orderData,
        returnRepresentation: true,
      );

      final orderList = jsonDecode(orderResponse.body) as List;
      if (orderList.isEmpty) {
        throw Exception('Failed to insert order header');
      }
      
      final createdOrderJson = orderList.first as Map<String, dynamic>;
      final int generatedOrderId = (createdOrderJson['id'] as num).toInt();

      // Step 2: Create the child order items
      final List<Map<String, dynamic>> itemsData = items.map((item) {
        final data = item.toJson();
        data.remove('id'); // DB auto-generates item UUID
        data['order_id'] = generatedOrderId; // Assign parent order ID
        return data;
      }).toList();

      // PostgREST bulk insert
      await _apiClient.post('/order_items', itemsData);

      // Step 3: Decrement stock levels for each item
      for (final item in items) {
        if (item.productId != null) {
          try {
            // First fetch current product stock
            final prodResponse = await _apiClient.get(
              '/products',
              queryParams: {
                'id': 'eq.${item.productId}',
                'select': 'stock',
              },
            );
            final prodList = jsonDecode(prodResponse.body) as List;
            if (prodList.isNotEmpty) {
              final currentStock = (prodList.first['stock'] as num).toInt();
              final newStock = currentStock - item.quantity;
              
              // Update stock in DB
              await _apiClient.patch(
                '/products',
                {'stock': newStock >= 0 ? newStock : 0},
                queryParams: {
                  'id': 'eq.${item.productId}',
                },
              );
            }
          } catch (e) {
            // Log stock update failure but do not crash the order placement
            print('Failed to update stock for product ${item.productId}: $e');
          }
        }
      }

      // Return the complete order by fetching it with embedded items
      final finalOrder = await getOrderById(generatedOrderId);
      if (finalOrder != null) {
        return finalOrder;
      }

      // Fallback fallback return
      return Order.fromJson({
        ...createdOrderJson,
        'order_items': itemsData,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get order details by ID
  Future<Order?> getOrderById(int orderId) async {
    try {
      final response = await _apiClient.get(
        '/orders',
        queryParams: {
          'id': 'eq.$orderId',
          'select': '*,order_items(*)',
        },
      );
      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return Order.fromJson(list.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get orders history for logged-in user
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final response = await _apiClient.get(
        '/orders',
        queryParams: {
          'user_id': 'eq.$userId',
          'select': '*,order_items(*)',
          'order': 'created_at.desc',
        },
      );
      final list = jsonDecode(response.body) as List;
      return list.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Guest order tracking (Order ID + Phone)
  Future<Order?> trackGuestOrder(int orderId, String phone) async {
    try {
      // Clean phone whitespace
      final cleanPhone = phone.trim();
      final response = await _apiClient.get(
        '/orders',
        queryParams: {
          'id': 'eq.$orderId',
          'customer_phone': 'eq.$cleanPhone',
          'select': '*,order_items(*)',
        },
      );
      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return Order.fromJson(list.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Admin: View all orders with filters (status, search queries)
  Future<List<Order>> getAllOrders({String? status, String? searchQuery}) async {
    try {
      final Map<String, String> params = {
        'select': '*,order_items(*)',
        'order': 'created_at.desc',
      };

      if (status != null && status.isNotEmpty && status != 'all') {
        params['status'] = 'eq.$status';
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Can filter on customer name or phone
        params['or'] = 'customer_name.ilike.*$searchQuery*,customer_phone.ilike.*$searchQuery*';
      }

      final response = await _apiClient.get('/orders', queryParams: params);
      final list = jsonDecode(response.body) as List;
      return list.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update order status (Admins, Staff, Super Admins)
  Future<Order> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _apiClient.patch(
        '/orders',
        {
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        returnRepresentation: true,
        queryParams: {
          'id': 'eq.$orderId',
        },
      );

      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        // Fetch complete order with items
        final updated = await getOrderById(orderId);
        if (updated != null) return updated;
        return Order.fromJson(list.first as Map<String, dynamic>);
      }
      throw Exception('Failed to update order status');
    } catch (e) {
      rethrow;
    }
  }
}
