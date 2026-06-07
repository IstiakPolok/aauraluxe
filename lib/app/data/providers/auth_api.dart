import 'dart:convert';
import 'package:get/get.dart';
import '../models/models.dart';
import 'api_client.dart';

class AuthApi extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Sign up with Email/Password
  Future<UserProfile?> signUp(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/v1/signup',
        {
          'email': email,
          'password': password,
        },
      );
      
      final data = jsonDecode(response.body);
      final userId = data['id'] ?? data['user']?['id'];
      
      if (userId == null) {
        throw Exception('Signup failed: user ID not found in response');
      }

      // Supabase returns the user. The database trigger automatically creates a profile.
      // We'll fetch the profile now.
      final profile = await getProfile(userId.toString());
      return profile;
    } catch (e) {
      rethrow;
    }
  }

  // Login with Email/Password
  Future<UserProfile?> login(String email, String password) async {
    try {
      // Supabase password flow
      final response = await _apiClient.post(
        '/auth/v1/token?grant_type=password',
        {
          'email': email,
          'password': password,
        },
      );
      
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'] as String;
      final user = data['user'] as Map<String, dynamic>;
      final userId = user['id'] as String;
      
      // Fetch user profile to get their role
      final profile = await getProfile(userId);
      final role = profile?.role ?? 'customer';

      // Save token and profile to API Client session
      await _apiClient.saveSession(
        token: accessToken,
        userId: userId,
        email: email,
        role: role,
      );

      return profile;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // We call logout on Supabase.
      await _apiClient.post('/auth/v1/logout', null);
    } catch (e) {
      // Ignore API logout failures (e.g. token already expired) and clear local session anyway
    } finally {
      await _apiClient.clearSession();
    }
  }

  // Get User Profile from profiles table
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _apiClient.get(
        '/profiles',
        queryParams: {
          'id': 'eq.$userId',
          'select': '*',
        },
      );

      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return UserProfile.fromJson(list.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile (e.g., admin updates a customer's role or details)
  Future<UserProfile?> updateProfile(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        '/profiles',
        data,
        returnRepresentation: true,
        queryParams: {
          'id': 'eq.$id',
        },
      );

      final list = jsonDecode(response.body) as List;
      if (list.isNotEmpty) {
        return UserProfile.fromJson(list.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get list of all profiles (Admins/Super Admins only)
  Future<List<UserProfile>> getAllProfiles() async {
    try {
      final response = await _apiClient.get(
        '/profiles',
        queryParams: {
          'order': 'created_at.desc',
        },
      );
      final list = jsonDecode(response.body) as List;
      return list.map((json) => UserProfile.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
