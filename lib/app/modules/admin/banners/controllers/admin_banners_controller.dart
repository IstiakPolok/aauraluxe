import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/promo_banner_api.dart';
import 'package:aauraluxe/app/data/providers/category_api.dart';
import 'package:aauraluxe/app/data/providers/activity_log_api.dart';

class AdminBannersController extends GetxController {
  final PromoBannerApi _bannerApi = Get.put(PromoBannerApi());
  final CategoryApi _categoryApi = Get.put(CategoryApi());
  final ActivityLogApi _activityLogApi = Get.put(ActivityLogApi());

  final RxList<PromoBanner> banners = <PromoBanner>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBanners();
    loadCategories();
  }

  Future<void> loadBanners() async {
    isLoading.value = true;
    try {
      final list = await _bannerApi.getBanners();
      banners.value = list;
    } catch (e) {
      print('Admin banners load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final list = await _categoryApi.getCategories();
      categories.value = list;
    } catch (e) {
      print('Admin categories load error in banners controller: $e');
    }
  }

  Future<void> createBanner({required String imageUrl, String? categoryId}) async {
    isLoading.value = true;
    try {
      final PromoBanner banner = PromoBanner(
        id: '',
        imageUrl: imageUrl,
        categoryId: categoryId,
        createdAt: DateTime.now(),
      );

      final result = await _bannerApi.createBanner(banner);
      await _activityLogApi.logAction(
        action: 'created_promo_banner',
        entityType: 'promo_banner',
        entityId: result.id,
      );

      Get.snackbar('Success', 'Promo banner added successfully.', snackPosition: SnackPosition.BOTTOM);
      loadBanners();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add banner: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBanner(String id) async {
    isLoading.value = true;
    try {
      await _bannerApi.deleteBanner(id);
      await _activityLogApi.logAction(
        action: 'deleted_promo_banner',
        entityType: 'promo_banner',
        entityId: id,
      );

      Get.snackbar('Deleted', 'Promo banner deleted successfully.', snackPosition: SnackPosition.BOTTOM);
      loadBanners();
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete banner: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
