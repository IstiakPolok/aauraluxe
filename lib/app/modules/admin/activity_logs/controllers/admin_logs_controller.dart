import 'package:get/get.dart';
import 'package:aauraluxe/app/data/models/models.dart';
import 'package:aauraluxe/app/data/providers/activity_log_api.dart';

class AdminLogsController extends GetxController {
  final ActivityLogApi _activityLogApi = Get.put(ActivityLogApi());

  final RxList<ActivityLog> logs = <ActivityLog>[].obs;
  final RxBool isLoading = false.obs;

  final RxString filterEmail = ''.obs;
  final RxString filterEntityType = 'all'.obs;
  final Rxn<DateTime> filterStartDate = Rxn<DateTime>();
  final Rxn<DateTime> filterEndDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadLogs();
  }

  Future<void> loadLogs() async {
    isLoading.value = true;
    try {
      final list = await _activityLogApi.getLogs(
        performerEmail: filterEmail.value.isEmpty ? null : filterEmail.value,
        entityType: filterEntityType.value,
        dateStart: filterStartDate.value?.toIso8601String(),
        dateEnd: filterEndDate.value?.toIso8601String(),
      );
      logs.value = list;
    } catch (e) {
      print('Admin logs load error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateEmailFilter(String email) {
    filterEmail.value = email;
    loadLogs();
  }

  void updateEntityTypeFilter(String type) {
    filterEntityType.value = type;
    loadLogs();
  }

  void updateDateRange(DateTime? start, DateTime? end) {
    filterStartDate.value = start;
    filterEndDate.value = end;
    loadLogs();
  }

  void clearFilters() {
    filterEmail.value = '';
    filterEntityType.value = 'all';
    filterStartDate.value = null;
    filterEndDate.value = null;
    loadLogs();
  }
}
