import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class AdminDashboardScreen extends StatelessWidget {
  final void Function(int, {String? filter}) onNavigateRequested;

  const AdminDashboardScreen({
    super.key,
    required this.onNavigateRequested,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AppAuthProvider>();
    final adminModel = authProvider.adminModel;
    final adminId = adminModel?.adminIdString ?? '';
    final adminName = adminModel?.name ?? authProvider.currentUser?.displayName ?? 'Admin';
    final department = adminModel?.department ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: StreamBuilder<List<ComplaintModel>>(
            stream: FirestoreService().streamAdminComplaints(adminId),
            builder: (context, snapshot) {
              final isLoading = snapshot.connectionState == ConnectionState.waiting;
              final allComplaints = snapshot.data ?? [];

              // Sort newest first
              final sortedComplaints = List<ComplaintModel>.from(allComplaints)
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

              final total = allComplaints.length;
              final pending = allComplaints.where((c) => c.status == AppStatuses.pending).length;
              final inProgress = allComplaints.where((c) => c.status == AppStatuses.inProgress).length;
              final resolved = allComplaints.where((c) => c.status == AppStatuses.resolved).length;
              
              final recentlyAdded = sortedComplaints.take(3).toList();

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  // Fake delay to show refresh animation since streams auto-update
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Welcome Banner
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_getGreeting(), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(adminName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                  if (department.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.business_outlined, size: 14, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(department, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ID: $adminId',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),
                    ),

                    // Overview heading
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, top: 20, bottom: 12),
                        child: const Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ).animate().fadeIn(delay: 100.ms),
                    ),

                    // Stats Cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final useGrid = constraints.maxWidth < 600;
                            final cards = [
                              _buildStatCard('Total', total, AppColors.primary, Icons.assignment_outlined, const Color(0xFFEFF6FF), 0),
                              _buildStatCard('Pending', pending, AppColors.warning, Icons.schedule, const Color(0xFFFFFBEB), 1),
                              _buildStatCard('In Progress', inProgress, AppColors.primary, Icons.settings_outlined, const Color(0xFFEFF6FF), 2),
                              _buildStatCard('Resolved', resolved, AppColors.secondary, Icons.check_circle_outline, const Color(0xFFF0FDF4), 3),
                            ];

                            if (useGrid) {
                              return Column(
                                children: [
                                  Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
                                  const SizedBox(height: 12),
                                  Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
                                ],
                              );
                            }
                            return Row(
                              children: cards.map((card) => Expanded(child: card)).toList()
                                ..insert(1, const Expanded(flex: 0, child: SizedBox(width: 12)))
                                ..insert(3, const Expanded(flex: 0, child: SizedBox(width: 12)))
                                ..insert(5, const Expanded(flex: 0, child: SizedBox(width: 12))),
                            );
                          },
                        ),
                      ),
                    ),

                    // Quick Actions
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 12),
                        child: const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ).animate().fadeIn(delay: 200.ms),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            // View All Complaints Card
                            Expanded(
                              child: _buildActionCard(
                                title: 'All Complaints',
                                count: total.toString(),
                                icon: Icons.content_paste_rounded,
                                gradientColors: [AppColors.primary, const Color(0xFF0EA5E9)],
                                onTap: () => onNavigateRequested(1),
                                delay: 300,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Pending Attention Card
                            Expanded(
                              child: _buildActionCard(
                                title: 'Need Attention',
                                count: (pending + inProgress).toString(),
                                icon: Icons.access_time_filled_rounded,
                                gradientColors: [AppColors.warning, AppColors.error],
                                onTap: () => onNavigateRequested(1, filter: AppStatuses.pending),
                                delay: 400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recent Activity
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            const Text('Latest 3 complaints', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                    ),

                    if (isLoading)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    else if (recentlyAdded.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text('No recent activity.', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final complaint = recentlyAdded[index];
                            return _buildCompactComplaintCard(complaint, index);
                          },
                          childCount: recentlyAdded.length,
                        ),
                      ),

                    // View All ->
                    if (!isLoading && recentlyAdded.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 24, top: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => onNavigateRequested(1),
                              icon: const Text('View All Complaints', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                              label: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 700.ms),
                      ),

                    // Department Info Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 40),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.business_outlined, size: 20, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Your Department', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                department.isNotEmpty ? department : 'No department assigned',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 16),
                              const Divider(height: 1, color: AppColors.borderLight),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.badge_outlined, size: 18, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  const Text('Admin ID', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text(adminId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: 'Copy ID',
                                    child: IconButton(
                                      icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: adminId));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Admin ID copied to clipboard'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: AppColors.secondary,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Share this ID with users so they can route complaints to you',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon, Color bgColor, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: count),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                value.toString(),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    ).animate()
     .fadeIn(duration: 350.ms, delay: (200 + index * 80).ms)
     .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 350.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildActionCard({
    required String title,
    required String count,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int delay,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: int.tryParse(count) ?? 0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    value.toString(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                  );
                },
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildCompactComplaintCard(ComplaintModel complaint, int index) {
    final statusColor = AppColors.statusColor(complaint.status);

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onNavigateRequested(1), // Switching to complaints tab
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: statusColor, width: 3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                      const SizedBox(height: 4),
                      Text(
                        '${complaint.category} • ${complaint.location}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        complaint.status,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Helpers.formatDate(complaint.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (500 + index * 100).ms).slideX(begin: 0.05),
    );
  }
}
