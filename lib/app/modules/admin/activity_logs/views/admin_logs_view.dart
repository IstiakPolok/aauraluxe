import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aauraluxe/app/core/theme.dart';
import '../controllers/admin_logs_controller.dart';

class AdminLogsView extends GetView<AdminLogsController> {
  const AdminLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final padding = isDesktop ? const EdgeInsets.all(AppTheme.s32) : const EdgeInsets.all(AppTheme.s16);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: padding,
        child: Column(
          children: [
            // Filter card header
            _buildFiltersCard(context, isDesktop),
            const SizedBox(height: AppTheme.s24),

            // Logs stream
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.logs.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildLogsList(context);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.s20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Audit Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextButton(
                onPressed: () => controller.clearFilters(),
                child: const Text('Clear Filters', style: TextStyle(color: AppTheme.error, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.s12),
          
          // Row / Column based filters
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildEmailFilterInput()),
                const SizedBox(width: AppTheme.s16),
                Expanded(child: _buildEntityTypeDropdown()),
                const SizedBox(width: AppTheme.s16),
                Expanded(child: _buildDatePicker(context)),
              ],
            )
          else
            Column(
              children: [
                _buildEmailFilterInput(),
                const SizedBox(height: AppTheme.s12),
                _buildEntityTypeDropdown(),
                const SizedBox(height: AppTheme.s12),
                _buildDatePicker(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmailFilterInput() {
    return TextFormField(
      onChanged: (val) => controller.updateEmailFilter(val),
      decoration: const InputDecoration(
        labelText: 'Admin Email',
        hintText: 'Search by performer email...',
        prefixIcon: Icon(Icons.person, size: 18),
        contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s12),
      ),
    );
  }

  Widget _buildEntityTypeDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.filterEntityType.value,
          decoration: const InputDecoration(
            labelText: 'Entity Type',
            contentPadding: EdgeInsets.symmetric(horizontal: AppTheme.s12, vertical: AppTheme.s12),
          ),
          items: ['all', 'product', 'order', 'category', 'user']
              .map((type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type.toUpperCase()),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) controller.updateEntityTypeFilter(val);
          },
        ));
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2025),
          lastDate: DateTime.now().add(const Duration(days: 1)),
          initialDateRange: controller.filterStartDate.value != null && controller.filterEndDate.value != null
              ? DateTimeRange(start: controller.filterStartDate.value!, end: controller.filterEndDate.value!)
              : null,
        );
        if (picked != null) {
          controller.updateDateRange(picked.start, picked.end);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.s16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: AppTheme.borderMedium,
          color: Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              if (controller.filterStartDate.value == null) {
                return const Text('Filter Date Range', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14));
              }
              final start = DateFormat('MM/dd').format(controller.filterStartDate.value!);
              final end = DateFormat('MM/dd').format(controller.filterEndDate.value!);
              return Text('$start - $end', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
            }),
            const Icon(Icons.date_range_outlined, color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_edu_outlined, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: AppTheme.s16),
          const Text('No audit logs recorded', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Actions performed by admin staff will appear in this feed.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLogsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderMedium,
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListView.separated(
        itemCount: controller.logs.length,
        separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
        itemBuilder: (context, index) {
          final log = controller.logs[index];
          final timestamp = DateFormat('MMM dd, yyyy • hh:mm a').format(log.timestamp);
          
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.s20, vertical: AppTheme.s8),
            leading: CircleAvatar(
              backgroundColor: AppTheme.background,
              child: Icon(_getLogIcon(log.entityType), color: AppTheme.primary, size: 18),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    log.performerEmail,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, overflow: TextOverflow.ellipsis),
                  ),
                ),
                _buildRoleBadge(log.performerRole),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Action: "${log.action.replaceAll('_', ' ')}" on ${log.entityType} (ID: ${log.entityId})',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timestamp,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getLogIcon(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'product':
        return Icons.inventory_2_outlined;
      case 'order':
        return Icons.shopping_bag_outlined;
      case 'category':
        return Icons.category_outlined;
      case 'user':
        return Icons.person_outline;
      default:
        return Icons.history_outlined;
    }
  }

  Widget _buildRoleBadge(String role) {
    Color bg;
    Color fg;
    switch (role.toLowerCase()) {
      case 'super_admin':
        bg = Colors.red.withOpacity(0.12);
        fg = Colors.red[800]!;
        break;
      case 'admin':
        bg = Colors.blue.withOpacity(0.12);
        fg = Colors.blue[800]!;
        break;
      case 'staff':
        bg = Colors.teal.withOpacity(0.12);
        fg = Colors.teal[800]!;
        break;
      default:
        bg = Colors.grey.withOpacity(0.12);
        fg = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
