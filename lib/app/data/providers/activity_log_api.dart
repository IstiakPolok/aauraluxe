import 'dart:convert';
import 'package:get/get.dart';
import '../models/models.dart';
import 'api_client.dart';

class ActivityLogApi extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // Write a log entry
  Future<void> logAction({
    required String action,
    required String entityType,
    required String entityId,
  }) async {
    // Only logged-in admin/staff members trigger logs
    if (!_apiClient.isAuthenticated) return;

    try {
      final logData = {
        'performer_id': _apiClient.userId,
        'performer_email': _apiClient.userEmail ?? 'unknown',
        'performer_role': _apiClient.userRole ?? 'staff',
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _apiClient.post('/activity_logs', logData);
    } catch (e) {
      // Fail silently for activity logging to prevent interrupting operational workflows
      print('ActivityLog error: $e');
    }
  }

  // Fetch audit logs (Super Admin only - validated by RLS)
  Future<List<ActivityLog>> getLogs({
    String? performerEmail,
    String? entityType,
    String? dateStart, // ISO-8601 string
    String? dateEnd,   // ISO-8601 string
  }) async {
    try {
      final Map<String, String> params = {
        'select': '*',
        'order': 'timestamp.desc',
      };

      if (performerEmail != null && performerEmail.isNotEmpty) {
        params['performer_email'] = 'ilike.*$performerEmail*';
      }

      if (entityType != null && entityType.isNotEmpty && entityType != 'all') {
        params['entity_type'] = 'eq.$entityType';
      }

      // Date range filtering
      if (dateStart != null && dateStart.isNotEmpty) {
        params['timestamp'] = 'gte.$dateStart';
      }
      if (dateEnd != null && dateEnd.isNotEmpty) {
        // If there's already a timestamp filter, PostgREST supports double constraints
        // via different filter operators or and-conditions. We'll check if gte is already set.
        if (params.containsKey('timestamp')) {
          final gteVal = params['timestamp']!;
          params.remove('timestamp');
          params['and'] = '($gteVal,timestamp.lte.$dateEnd)';
        } else {
          params['timestamp'] = 'lte.$dateEnd';
        }
      }

      final response = await _apiClient.get('/activity_logs', queryParams: params);
      final list = jsonDecode(response.body) as List;
      return list.map((json) => ActivityLog.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
