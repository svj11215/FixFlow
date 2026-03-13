import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/complaint_card.dart';
import '../../widgets/manage_complaint_sheet.dart';
import '../../widgets/stats_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final adminId = authProvider.adminModel?.adminIdString ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.adminDashboard,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin/profile');
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              backgroundImage: authProvider.currentUser?.photoURL != null
                  ? NetworkImage(authProvider.currentUser!.photoURL!)
                  : null,
              child: authProvider.currentUser?.photoURL == null
                  ? const Icon(Icons.person, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: StreamBuilder<List<ComplaintModel>>(
            stream: FirestoreService().streamAdminComplaints(adminId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }

              final allComplaints = snapshot.data ?? [];
              final pending = allComplaints
                  .where((c) => c.status == 'Pending')
                  .length;
              final resolved = allComplaints
                  .where((c) => c.status == 'Resolved')
                  .length;

              final filteredComplaints = _statusFilter == 'All'
                  ? allComplaints
                  : allComplaints
                      .where((c) => c.status == _statusFilter)
                      .toList();

              return Column(
                children: [
                  // Stats Row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        StatsCard(
                          label: 'Total',
                          count: allComplaints.length,
                          color: AppColors.primary,
                          icon: Icons.list_alt,
                        ),
                        const SizedBox(width: 12),
                        StatsCard(
                          label: 'Pending',
                          count: pending,
                          color: AppColors.warning,
                          icon: Icons.pending_actions,
                        ),
                        const SizedBox(width: 12),
                        StatsCard(
                          label: 'Resolved',
                          count: resolved,
                          color: AppColors.secondary,
                          icon: Icons.check_circle_outline,
                        ),
                      ],
                    ),
                  ),
                  // Filter Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          isExpanded: true,
                          icon: const Icon(Icons.filter_list),
                          items: AppStatuses.filterStatuses.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text('Filter: $status'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _statusFilter = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Complaint List
                  Expanded(
                    child: filteredComplaints.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 48, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                Text(
                                  _statusFilter == 'All'
                                      ? 'No complaints yet'
                                      : 'No $_statusFilter complaints',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredComplaints.length,
                            itemBuilder: (context, index) {
                              final complaint = filteredComplaints[index];
                              return ComplaintCard(
                                complaint: complaint,
                                isAdmin: true,
                                onManage: () =>
                                    _openManageSheet(context, complaint),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openManageSheet(BuildContext context, ComplaintModel complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => ManageComplaintSheet(
          complaint: complaint,
          onUpdate: (status, note) async {
            final provider = context.read<ComplaintProvider>();
            return provider.updateComplaint(complaint.id, status, note);
          },
        ),
      ),
    );
  }
}
