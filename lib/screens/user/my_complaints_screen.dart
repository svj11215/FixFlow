import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/complaint_card.dart';

class MyComplaintsScreen extends StatefulWidget {
  const MyComplaintsScreen({super.key});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<ComplaintModel>>(
        stream: context.read<ComplaintProvider>().userComplaints(userId),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final complaints = snapshot.data ?? [];
          
          // Calculate stats
          final total = complaints.length;
          final pending = complaints.where((c) => c.status == AppStatuses.pending).length;
          final inProgress = complaints.where((c) => c.status == AppStatuses.inProgress).length;
          final resolved = complaints.where((c) => c.status == AppStatuses.resolved).length;
          final rejected = complaints.where((c) => c.status == AppStatuses.rejected).length;

          // Filter complaints
          final filteredComplaints = _selectedFilter == 'All'
              ? complaints
              : complaints.where((c) => c.status == _selectedFilter).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Complaints',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Track the status of your reported issues.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Stats Grid
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: _buildStatCard(context, 'Total', total, Icons.analytics_outlined, AppColors.primary)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildStatCard(context, 'Pending', pending, Icons.schedule, AppColors.warning)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildStatCard(context, 'Resolved', resolved, Icons.check_circle_outline, AppColors.secondary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final cardWidth = constraints.maxWidth * 0.45;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(width: cardWidth, child: _buildStatCard(context, 'In Progress', inProgress, Icons.sync, AppColors.accentTeal)),
                                      SizedBox(width: constraints.maxWidth * 0.10 - 1), // gap
                                      SizedBox(width: cardWidth, child: _buildStatCard(context, 'Rejected', rejected, Icons.cancel_outlined, AppColors.error)),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                          
                          const SizedBox(height: 24),
                          
                          // Filters
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = MediaQuery.sizeOf(context).width < 600;
                              final chips = AppStatuses.filterStatuses.map((filter) {
                                final isSelected = _selectedFilter == filter;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: isMobile ? EdgeInsets.zero : const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(
                                      filter,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                        fontSize: isMobile ? 11 : 13,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) setState(() => _selectedFilter = filter);
                                    },
                                    backgroundColor: Colors.white,
                                    selectedColor: AppColors.primary,
                                    showCheckmark: false,
                                    elevation: isSelected ? 4 : 0,
                                    pressElevation: 0,
                                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                                    padding: isMobile ? const EdgeInsets.symmetric(horizontal: 4, vertical: 0) : null,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList();

                              if (isMobile) {
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: chips,
                                );
                              } else {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: chips,
                                );
                              }
                            },
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.1),
                        ],
                      ),
                    ),
                  ),

                  // Content List
                  if (isLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildShimmerCard(),
                          childCount: 3,
                        ),
                      ),
                    )
                  else if (filteredComplaints.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.inbox_rounded, size: 60, color: AppColors.primary),
                            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 24),
                            Text(
                              _selectedFilter == 'All' 
                                  ? 'No complaints yet' 
                                  : 'No $_selectedFilter complaints',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFilter == 'All'
                                  ? 'When you submit complaints, they will appear here.'
                                  : 'Try changing the filter to see other complaints.',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ).animate().fadeIn(delay: 300.ms),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return ComplaintCard(
                              complaint: filteredComplaints[index],
                              onDelete: () => _deleteComplaint(context, filteredComplaints[index].id),
                            ).animate()
                             .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                             .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
                          },
                          childCount: filteredComplaints.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, int count, IconData icon, Color color) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(begin: 0, end: count.toDouble()),
            builder: (context, value, child) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 150, height: 20, color: Colors.white),
                Container(width: 80, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              ],
            ),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 14, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 250, height: 14, color: Colors.white),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(width: 20, height: 20, color: Colors.white),
                const SizedBox(width: 8),
                Container(width: 100, height: 14, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteComplaint(BuildContext context, String complaintId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = context.read<ComplaintProvider>();
    try {
      final success = await provider.deleteComplaint(complaintId);
      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Complaint deleted successfully'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to delete complaint'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
