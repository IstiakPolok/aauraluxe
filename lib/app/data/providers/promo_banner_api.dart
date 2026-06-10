import 'dart:convert';
import 'package:get/get.dart';
import '../models/models.dart';
import 'api_client.dart';

class PromoBannerApi extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Fetch all promo banners
  Future<List<PromoBanner>> getBanners() async {
    try {
      final response = await _apiClient.get(
        '/promo_banners',
        queryParams: {
          'select': '*',
          'order': 'created_at.desc',
        },
      );
      final list = jsonDecode(response.body) as List;
      return list.map((json) => PromoBanner.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create a promo banner (Admins only)
  Future<PromoBanner> createBanner(PromoBanner banner) async {
    try {
      final data = banner.toJson();
      data.remove('id'); // DB auto-generates UUID

      final response = await _apiClient.post(
        '/promo_banners',
        data,
        returnRepresentation: true,
      );

      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return PromoBanner.fromJson(list.first as Map<String, dynamic>);
      }
      throw Exception('Failed to create promo banner');
    } catch (e) {
      rethrow;
    }
  }

  // Delete a promo banner (Admins only)
  Future<void> deleteBanner(String id) async {
    try {
      await _apiClient.delete(
        '/promo_banners',
        queryParams: {
          'id': 'eq.$id',
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
