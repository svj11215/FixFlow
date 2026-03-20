import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/manage_complaint_sheet.dart';

class AdminComplaintsScreen extends StatefulWidget {
  final String? initialFilter;

  const AdminComplaintsScreen({super.key, this.initialFilter});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  String _statusFilter = 'All';
  String _searchQuery = '';
  bool _newestFirst = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialFilter != null && widget.initialFilter != 'All') {
      _statusFilter = widget.initialFilter!;
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void didUpdateWidget(AdminComplaintsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != null && widget.initialFilter != oldWidget.initialFilter) {
      if (mounted) {
        setState(() {
          _statusFilter = widget.initialFilter!;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openManageSheet(ComplaintModel complaint) {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AppAuthProvider>();
    final adminId = authProvider.adminModel?.adminIdString ?? '';

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

              // Calculate status counts for filter chips
              final statusCounts = <String, int>{
                'All': allComplaints.length,
                AppStatuses.pending: allComplaints.where((c) => c.status == AppStatuses.pending).length,
                AppStatuses.inProgress: allComplaints.where((c) => c.status == AppStatuses.inProgress).length,
                AppStatuses.resolved: allComplaints.where((c) => c.status == AppStatuses.resolved).length,
                AppStatuses.rejected: allComplaints.where((c) => c.status == AppStatuses.rejected).length,
              };

              // Apply Filters (Status + Search)
              var filteredList = allComplaints.where((c) {
                final matchStatus = _statusFilter == 'All' || c.status == _statusFilter;
                final matchSearch = _searchQuery.isEmpty ||
                    c.title.toLowerCase().contains(_searchQuery) ||
                    c.description.toLowerCase().contains(_searchQuery) ||
                    c.location.toLowerCase().contains(_searchQuery) ||
                    c.category.toLowerCase().contains(_searchQuery);
                return matchStatus && matchSearch;
              }).toList();

              // Apply Sort
              filteredList.sort((a, b) {
                return _newestFirst ? b.createdAt.compareTo(a.createdAt) : a.createdAt.compareTo(b.createdAt);
              });

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header Row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Complaints',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${filteredList.length} total',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms),
                      ),
                    ),

                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search complaints...',
                              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                                      onPressed: () => _searchController.clear(),
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      ),
                    ),

                    // Filter Chips Row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: AppStatuses.filterStatuses.map((filter) {
                            final isSelected = _statusFilter == filter;
                            final count = statusCounts[filter] ?? 0;
                            return FilterChip(
                              label: Text('$filter ($count)'),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) setState(() => _statusFilter = filter);
                              },
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFF1565C0),
                              selectedShadowColor: const Color(0xFF1565C0).withValues(alpha: 0.3),
                              showCheckmark: false,
                              elevation: isSelected ? 2 : 0,
                              pressElevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFDDDDDD),
                                ),
                              ),
                            );
                          }).toList(),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                      ),
                    ),

                    // Sort Row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Sort by:', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            const SizedBox(width: 8),
                            DropdownButton<bool>(
                              value: _newestFirst,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                              underline: const SizedBox(),
                              style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                              items: const [
                                DropdownMenuItem(value: true, child: Text('Newest First')),
                                DropdownMenuItem(value: false, child: Text('Oldest First')),
                              ],
                              onChanged: (value) {
                                if (value != null) setState(() => _newestFirst = value);
                              },
                            ),
                          ],
                        ).animate().fadeIn(delay: 300.ms),
                      ),
                    ),

                    // Complaint List
                    if (isLoading)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, index) => _buildShimmerCard(),
                            childCount: 4,
                          ),
                        ),
                      )
                    else if (filteredList.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final complaint = filteredList[index];
                              return _buildDetailedCard(complaint, index)
                                  .animate(key: ValueKey(complaint.id))
                                  .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                                  .slideY(begin: 0.05, duration: 300.ms, curve: Curves.easeOutCubic);
                            },
                            childCount: filteredList.length,
                          ),
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

  Widget _buildEmptyState() {
    String title = 'No complaints found';
    String subtitle = 'No complaints assigned to your Admin ID yet';

    if (_searchQuery.isNotEmpty) {
      subtitle = 'No results for "$_searchQuery"';
    } else if (_statusFilter != 'All') {
      subtitle = 'No $_statusFilter complaints';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: const Color(0xFFCBD5E1))
              .animate()
              .scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary))
              .animate()
              .fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14), textAlign: TextAlign.center)
              .animate()
              .fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _statusFilter != 'All')
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() => _statusFilter = 'All');
              },
              icon: const Icon(Icons.clear, size: 16, color: AppColors.textSecondary),
              label: const Text('Clear Filters', style: TextStyle(color: AppColors.textSecondary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.borderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildDetailedCard(ComplaintModel complaint, int index) {
    final statusColor = AppColors.statusColor(complaint.status);
    final descLimit = 80;
    final truncatedDesc = complaint.description.length > descLimit
        ? '${complaint.description.substring(0, descLimit)}...'
        : complaint.description;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _openManageSheet(complaint),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: statusColor, width: 4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Title + Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        complaint.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        complaint.status,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Content Row: (Meta + Desc) / Image
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 2: Category & Location
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: BoxDecoration(color: AppCategories.categoryColor(complaint.category), shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  complaint.category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  complaint.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Row 3: Submitted by & Date
                          Row(
                            children: [
                              const Icon(Icons.person, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'by ${complaint.userName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  Helpers.formatDate(complaint.createdAt),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Row 4: Description preview
                          Text(
                            '"$truncatedDesc"',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    if (complaint.imageUrl.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: CachedNetworkImage(
                            imageUrl: complaint.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[200]),
                            errorWidget: (context, url, error) => Container(color: Colors.grey[100], child: const Icon(Icons.broken_image, color: Colors.grey, size: 24)),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                
                // Resolution Note preview if exists
                if (complaint.resolutionNote.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Admin Note: ${complaint.resolutionNote}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.background),
                const SizedBox(height: 12),

                // Bottom Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tap Anywhere to Manage', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                    Row(
                      children: const [
                        Text('Manage', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(18),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 200, height: 16, color: Colors.white),
                Container(width: 60, height: 20, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 150, height: 12, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(width: 180, height: 12, color: Colors.white),
                      const SizedBox(height: 16),
                      Container(width: double.infinity, height: 10, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 200, height: 10, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 120, height: 10, color: Colors.white),
                Container(width: 60, height: 14, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
