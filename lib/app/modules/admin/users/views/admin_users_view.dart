import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aauraluxe/app/core/theme.dart';
import 'package:aauraluxe/app/data/models/user_profile.dart';
import '../controllers/admin_users_controller.dart';
import 'package:intl/intl.dart';

class AdminUsersView extends GetView<AdminUsersController> {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    // We register the controller locally if it wasn't bound by routing yet
    // since this view is injected as a panel in the dashboard.
    if (!Get.isRegistered<AdminUsersController>()) {
      Get.put(AdminUsersController());
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.loadUsers(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.s24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.borderMedium,
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Obx(() {
                  if (controller.isLoading.value && controller.users.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (controller.users.isEmpty) {
                    return const Center(child: Text('No users found.', style: TextStyle(color: AppTheme.textSecondary)));
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith((states) => AppTheme.background),
                        columns: const [
                          DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Joined Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: controller.users.map((user) => _buildUserRow(context, user)).toList(),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildUserRow(BuildContext context, UserProfile user) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return DataRow(
      cells: [
        DataCell(Text(user.email, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(_buildRoleChip(user.role)),
        DataCell(_buildStatusChip(user.isBlocked)),
        DataCell(Text(dateFormat.format(user.createdAt), style: const TextStyle(color: AppTheme.textSecondary))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20),
                tooltip: 'Edit Role',
                onPressed: () => _showEditRoleDialog(context, user),
              ),
              IconButton(
                icon: Icon(
                  user.isBlocked ? Icons.lock_open_outlined : Icons.block_outlined,
                  color: user.isBlocked ? Colors.green : AppTheme.error,
                  size: 20,
                ),
                tooltip: user.isBlocked ? 'Unblock User' : 'Block User',
                onPressed: () => _showBlockConfirmDialog(context, user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    switch (role) {
      case 'super_admin':
        color = Colors.deepPurple;
        break;
      case 'admin':
        color = Colors.blue;
        break;
      case 'staff':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildStatusChip(bool isBlocked) {
    final color = isBlocked ? AppTheme.error : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isBlocked ? 'BLOCKED' : 'ACTIVE',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, UserProfile user) {
    String selectedRole = user.role;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Change User Role'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select a new role for ${user.email}'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Role',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text('Customer')),
                    DropdownMenuItem(value: 'staff', child: Text('Staff')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRole = val);
                  },
                ),
              ],
            );
          }
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.updateUserRole(user.id, selectedRole);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text('Save Role'),
          ),
        ],
      ),
    );
  }

  void _showBlockConfirmDialog(BuildContext context, UserProfile user) {
    final isBlocking = !user.isBlocked;
    
    Get.dialog(
      AlertDialog(
        title: Text(isBlocking ? 'Block User?' : 'Unblock User?'),
        content: Text(
          isBlocking 
            ? 'Are you sure you want to block ${user.email}? They will not be able to log in to their account anymore.'
            : 'Are you sure you want to unblock ${user.email}? They will regain access to their account.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.toggleBlockStatus(user.id, user.isBlocked);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocking ? AppTheme.error : Colors.green, 
              foregroundColor: Colors.white
            ),
            child: Text(isBlocking ? 'Block User' : 'Unblock User'),
          ),
        ],
      ),
    );
  }
}
