import 'package:get/get.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/api_client.dart';
import '../../../data/providers/auth_api.dart';
import '../../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthApi _authApi = Get.put(AuthApi());
  final ApiClient _apiClient = Get.find<ApiClient>();

  final Rxn<UserProfile> currentUser = Rxn<UserProfile>();
  final RxBool isLoading = false.obs;

  bool get isAuthenticated => currentUser.value != null;
  UserProfile? get profile => currentUser.value;

  @override
  void onInit() {
    super.onInit();
    // Load current profile if already authenticated
    _checkInitialAuth();
  }

  void _checkInitialAuth() {
    if (_apiClient.isAuthenticated && _apiClient.userId != null) {
      currentUser.value = UserProfile(
        id: _apiClient.userId!,
        email: _apiClient.userEmail ?? '',
        role: _apiClient.userRole ?? 'customer',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<bool> login(String email, String password, {bool redirect = true}) async {
    isLoading.value = true;
    try {
      final userProfile = await _authApi.login(email, password);
      if (userProfile != null) {
        if (userProfile.isBlocked) {
          await _authApi.logout();
          Get.snackbar('Account Blocked', 'Your account has been suspended. Please contact support.', snackPosition: SnackPosition.BOTTOM);
          return false;
        }
        currentUser.value = userProfile;
        
        if (redirect) {
          // Navigation based on role
          if (userProfile.isAdmin || userProfile.isStaff) {
            Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
          } else {
            Get.offAllNamed(AppRoutes.CUSTOMER_HOME);
          }
        }
        Get.snackbar('Success', 'Welcome back, ${userProfile.email}!', snackPosition: SnackPosition.BOTTOM);
        return true;
      }
      return false;
    } catch (e) {
      // Errors are already handled and shown as snacks in ApiClient, but we can catch here
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    isLoading.value = true;
    try {
      final userProfile = await _authApi.signUp(email, password);
      if (userProfile != null) {
        // Sign up succeeded, let's automatically log them in
        return await login(email, password);
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authApi.logout();
      currentUser.value = null;
      Get.offAllNamed(AppRoutes.CUSTOMER_HOME);
      Get.snackbar('Logged Out', 'You have been successfully signed out.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to log out properly: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
