import 'dart:convert';
import 'package:get/get.dart';
import '../models/models.dart';
import 'api_client.dart';

class ReviewApi extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<List<ProductReview>> getProductReviews(String productId) async {
    try {
      final response = await _apiClient.get(
        '/product_reviews',
        queryParams: {
          'product_id': 'eq.$productId',
          'select': '*,profiles(email)',
          'order': 'created_at.desc',
        },
      );
      
      final list = jsonDecode(response.body) as List;
      return list.map((e) => ProductReview.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Failed to get product reviews: $e');
      return [];
    }
  }

  Future<bool> submitReview(String productId, int rating, String comment) async {
    if (!_apiClient.isAuthenticated || _apiClient.userId == null) {
      Get.snackbar('Error', 'You must be logged in to leave a review.');
      return false;
    }

    try {
      final response = await _apiClient.post(
        '/product_reviews',
        {
          'product_id': productId,
          'user_id': _apiClient.userId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Get.snackbar('Success', 'Your review has been submitted!', snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        // If it fails with 403 or RLS error
        Get.snackbar('Error', 'You can only review products you have purchased and received.');
        return false;
      }
    } catch (e) {
      // Supabase RLS throws an error if policy fails (e.g. they haven't bought it)
      if (e.toString().contains('42501') || e.toString().contains('new row violates row-level security')) {
        Get.snackbar('Permission Denied', 'You can only review products that have been delivered to you.', snackPosition: SnackPosition.BOTTOM);
      } else if (e.toString().contains('unique')) {
        Get.snackbar('Error', 'You have already submitted a review for this product.', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to submit review. You might not be eligible to review this product.', snackPosition: SnackPosition.BOTTOM);
      }
      return false;
    }
  }
}
