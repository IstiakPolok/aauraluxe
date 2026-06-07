import 'dart:convert';
import 'package:get/get.dart';
import '../models/models.dart';
import 'api_client.dart';

class CategoryApi extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Fetch all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiClient.get(
        '/categories',
        queryParams: {
          'select': '*',
          'order': 'name.asc',
        },
      );
      final list = jsonDecode(response.body) as List;
      return list.map((json) => Category.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create a category (Admins/Super Admins only)
  Future<Category> createCategory(Category category) async {
    try {
      final data = category.toJson();
      data.remove('id'); // DB auto-generates UUID

      final response = await _apiClient.post(
        '/categories',
        data,
        returnRepresentation: true,
      );

      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return Category.fromJson(list.first as Map<String, dynamic>);
      }
      throw Exception('Failed to create category');
    } catch (e) {
      rethrow;
    }
  }

  // Update a category (Admins/Super Admins only)
  Future<Category> updateCategory(String id, Category category) async {
    try {
      final data = category.toJson();
      data.remove('id');

      final response = await _apiClient.patch(
        '/categories',
        data,
        returnRepresentation: true,
        queryParams: {
          'id': 'eq.$id',
        },
      );

      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return Category.fromJson(list.first as Map<String, dynamic>);
      }
      throw Exception('Failed to update category');
    } catch (e) {
      rethrow;
    }
  }

  // Delete a category (Admins/Super Admins only)
  Future<void> deleteCategory(String id) async {
    try {
      await _apiClient.delete(
        '/categories',
        queryParams: {
          'id': 'eq.$id',
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
