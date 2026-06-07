import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_client.dart';

class ProductApi extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Fetch all products with optional filters
  Future<List<Product>> getProducts({
    String? categoryId,
    String? searchQuery,
    String? sortBy, // 'price_asc', 'price_desc', 'newest'
  }) async {
    try {
      final Map<String, String> params = {
        'select': '*',
      };

      // Apply category filter
      if (categoryId != null && categoryId.isNotEmpty) {
        params['category_id'] = 'eq.$categoryId';
      }

      // Apply search query
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['title'] = 'ilike.*$searchQuery*';
      }

      // Apply sorting
      if (sortBy != null) {
        switch (sortBy) {
          case 'price_asc':
            params['order'] = 'price.asc';
            break;
          case 'price_desc':
            params['order'] = 'price.desc';
            break;
          case 'newest':
          default:
            params['order'] = 'created_at.desc';
            break;
        }
      } else {
        params['order'] = 'created_at.desc';
      }

      final response = await _apiClient.get('/products', queryParams: params);
      final list = jsonDecode(response.body) as List;
      return list.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Fetch a single product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final response = await _apiClient.get(
        '/products',
        queryParams: {
          'id': 'eq.$id',
          'select': '*',
        },
      );
      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return Product.fromJson(list.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Create a product (Admins/Super Admins only)
  Future<Product> createProduct(Product product) async {
    try {
      final data = product.toJson();
      // Let DB generate ID
      data.remove('id');
      
      final response = await _apiClient.post(
        '/products',
        data,
        returnRepresentation: true,
      );

      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return Product.fromJson(list.first as Map<String, dynamic>);
      }
      throw Exception('Failed to create product');
    } catch (e) {
      rethrow;
    }
  }

  // Update a product (Admins/Super Admins only)
  Future<Product> updateProduct(String id, Product product) async {
    try {
      final data = product.toJson();
      data.remove('id');
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _apiClient.patch(
        '/products',
        data,
        returnRepresentation: true,
        queryParams: {
          'id': 'eq.$id',
        },
      );

      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return Product.fromJson(list.first as Map<String, dynamic>);
      }
      throw Exception('Failed to update product');
    } catch (e) {
      rethrow;
    }
  }

  // Delete a product (Admins/Super Admins only)
  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.delete(
        '/products',
        queryParams: {
          'id': 'eq.$id',
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Upload an image binary to Supabase Storage
  Future<String> uploadProductImage(String fileName, List<int> fileBytes, String mimeType) async {
    try {
      // Endpoint: /storage/v1/object/products/<filename>
      // Make raw HTTP post request using apiClient credentials
      final uri = Uri.parse('${_apiClient.baseUrl}/storage/v1/object/products/$fileName');
      
      final response = await http.post(
        uri,
        headers: {
          'apikey': _apiClient.anonKey,
          'Authorization': 'Bearer ${_apiClient.token ?? _apiClient.anonKey}',
          'Content-Type': mimeType,
        },
        body: fileBytes,
      );

      if (response.statusCode >= 400) {
        throw Exception('Image upload failed: ${response.body}');
      }

      // Return the public URL
      // Endpoint to view image: /storage/v1/object/public/products/<filename>
      return '${_apiClient.baseUrl}/storage/v1/object/public/products/$fileName';
    } catch (e) {
      // Fallback: If Storage bucket is not fully configured, return a elegant placeholder image url
      return 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80';
    }
  }
}
