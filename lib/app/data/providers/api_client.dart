import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient extends GetxService {
  // Replace these with your actual Supabase credentials or load them dynamically
  static const String defaultUrl = 'https://eafdkbuqbdodrlivmmxr.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVhZmRrYnVxYmRvZHJsaXZtbXhyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA4MTMzMDgsImV4cCI6MjA5NjM4OTMwOH0.8hyyjzxOpUx8cGQsBPZtKf-vp3mbKOfISHx-aLhqdYI';

  late String baseUrl;
  late String anonKey;

  final _token = RxnString();
  final _userId = RxnString();
  final _userEmail = RxnString();
  final _userRole = RxnString();

  String? get token => _token.value;
  String? get userId => _userId.value;
  String? get userEmail => _userEmail.value;
  String? get userRole => _userRole.value;

  bool get isAuthenticated => _token.value != null;
  bool get isSuperAdmin => _userRole.value == 'super_admin';
  bool get isAdmin =>
      _userRole.value == 'admin' || _userRole.value == 'super_admin';
  bool get isStaff =>
      _userRole.value == 'staff' ||
      _userRole.value == 'admin' ||
      _userRole.value == 'super_admin';

  late SharedPreferences _prefs;

  Future<ApiClient> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Load config or defaults
    baseUrl = _prefs.getString('supabase_url') ?? defaultUrl;
    anonKey = _prefs.getString('supabase_anon_key') ?? defaultAnonKey;

    // Clean trailing slash if present
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // Restore session
    _token.value = _prefs.getString('session_token');
    _userId.value = _prefs.getString('user_id');
    _userEmail.value = _prefs.getString('user_email');
    _userRole.value = _prefs.getString('user_role');

    return this;
  }

  Future<void> updateCredentials(String url, String key) async {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    anonKey = key;
    await _prefs.setString('supabase_url', baseUrl);
    await _prefs.setString('supabase_anon_key', key);
  }

  Future<void> saveSession({
    required String token,
    required String userId,
    required String email,
    required String role,
  }) async {
    _token.value = token;
    _userId.value = userId;
    _userEmail.value = email;
    _userRole.value = role;

    await _prefs.setString('session_token', token);
    await _prefs.setString('user_id', userId);
    await _prefs.setString('user_email', email);
    await _prefs.setString('user_role', role);
  }

  Future<void> clearSession() async {
    _token.value = null;
    _userId.value = null;
    _userEmail.value = null;
    _userRole.value = null;

    await _prefs.remove('session_token');
    await _prefs.remove('user_id');
    await _prefs.remove('user_email');
    await _prefs.remove('user_role');
  }

  Map<String, String> _getHeaders({bool includePrefer = false}) {
    final Map<String, String> headers = {
      'apikey': anonKey,
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (includePrefer) {
      // Tells Supabase to return the inserted/updated record
      headers['Prefer'] = 'return=representation';
    }
    return headers;
  }

  // Core Request Methods
  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await http.get(uri, headers: _getHeaders());
      _checkResponse(response);
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<http.Response> post(
    String path,
    dynamic body, {
    bool returnRepresentation = false,
  }) async {
    final uri = _buildUri(path);
    try {
      final response = await http.post(
        uri,
        headers: _getHeaders(includePrefer: returnRepresentation),
        body: body != null ? jsonEncode(body) : null,
      );
      _checkResponse(response);
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<http.Response> patch(
    String path,
    dynamic body, {
    bool returnRepresentation = false,
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await http.patch(
        uri,
        headers: _getHeaders(includePrefer: returnRepresentation),
        body: body != null ? jsonEncode(body) : null,
      );
      _checkResponse(response);
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(path, queryParams);
    try {
      final response = await http.delete(uri, headers: _getHeaders());
      _checkResponse(response);
      return response;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    String cleanPath = path;
    if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }

    // Handle auth path vs rest/v1 path
    String fullUrl;
    if (cleanPath.startsWith('/auth/v1')) {
      fullUrl = '$baseUrl$cleanPath';
    } else {
      fullUrl = '$baseUrl/rest/v1$cleanPath';
    }

    if (queryParams != null && queryParams.isNotEmpty) {
      // Construct query string manually to prevent url encoding issues with PostgREST syntax
      final buffer = StringBuffer(fullUrl);
      buffer.write('?');
      final list = <String>[];
      queryParams.forEach((key, value) {
        list.add('$key=${Uri.encodeQueryComponent(value)}');
      });
      buffer.write(list.join('&'));
      return Uri.parse(buffer.toString());
    }

    return Uri.parse(fullUrl);
  }

  void _checkResponse(http.Response response) {
    print('--- SUPABASE API DEBUG LOG ---');
    print('Request: ${response.request?.method} ${response.request?.url}');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('--------------------------------');

    if (response.statusCode >= 400) {
      final body = response.body;
      try {
        final parsed = jsonDecode(body);
        final message =
            parsed['message'] ??
            parsed['error_description'] ??
            'API Error occurred';
        throw ApiException(
          message: message.toString(),
          statusCode: response.statusCode,
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          message: 'Request failed with status code ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    }
  }

  void _handleError(dynamic error) {
    if (error is ApiException) {
      Get.snackbar('Error', error.message, snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar(
        'Connection Error',
        'Failed to connect to backend: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException(code: $statusCode, msg: $message)';
}
