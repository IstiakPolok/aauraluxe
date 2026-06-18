import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/user_profile.dart';
import 'package:aauraluxe/app/data/providers/auth_api.dart';

class AdminUsersController extends GetxController {
  final AuthApi _authApi = Get.find<AuthApi>();

  final RxList<UserProfile> users = <UserProfile>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    try {
      final list = await _authApi.getAllProfiles();
      users.value = list;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    isLoading.value = true;
    try {
      final updatedProfile = await _authApi.updateProfile(userId, {'role': newRole});
      if (updatedProfile != null) {
        final index = users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          users[index] = updatedProfile;
        }
        Get.snackbar('Success', 'User role updated successfully.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user role: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBlockStatus(String userId, bool currentBlockStatus) async {
    isLoading.value = true;
    try {
      final updatedProfile = await _authApi.updateProfile(userId, {'is_blocked': !currentBlockStatus});
      if (updatedProfile != null) {
        final index = users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          users[index] = updatedProfile;
        }
        Get.snackbar('Success', updatedProfile.isBlocked ? 'User blocked successfully.' : 'User unblocked successfully.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update block status: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
