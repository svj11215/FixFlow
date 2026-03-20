import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import 'admin_dashboard_screen.dart';
import 'admin_complaints_screen.dart';
import 'admin_profile_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final int initialTabIndex;
  final String? initialFilter;

  const AdminHomeScreen({
    super.key,
    this.initialTabIndex = 0,
    this.initialFilter,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late int _currentIndex;
  String? _pendingFilter;
  


  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    if (widget.initialFilter != null) {
      _pendingFilter = widget.initialFilter;
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  void _switchToTab(int index, {String? filter}) {
    setState(() {
      _currentIndex = index;
      if (filter != null) {
        _pendingFilter = filter;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final adminModel = authProvider.adminModel;
    final adminId = adminModel?.adminIdString ?? '';
    final photoUrl = safePhotoUrl(authProvider.currentUser);
    final adminName = adminModel?.name ?? authProvider.currentUser?.displayName ?? 'Admin';
    final firstName = adminName.trim().isNotEmpty ? adminName.trim().split(' ')[0] : 'Admin';

    final String? filterToPass = _pendingFilter;
    if (_pendingFilter != null && _currentIndex == 1) {
      // Consume the filter once passed to complaints tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _pendingFilter = null);
      });
    }

    final List<Widget> pages = [
      AdminDashboardScreen(onNavigateRequested: _switchToTab),
      AdminComplaintsScreen(initialFilter: filterToPass),
      const AdminProfileScreen(),
    ];

    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 60,
        titleSpacing: 12,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.build_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              'FixFlow',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Admin',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _switchToTab(2),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white24,
                ),
                child: _buildProfileAvatar(photoUrl, firstName, 16),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              children: [
                _buildNavigationRail(adminId),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: pages,
                  ),
                ),
              ],
            );
          }
          return IndexedStack(
            index: _currentIndex,
            children: pages,
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) return const SizedBox.shrink();
          return _buildBottomNavigationBar(adminId);
        },
      ),
    );
  }

  Widget _buildNavigationRail(String adminId) {
    return Container(
      width: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.borderLight, width: 1.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildRailItem(0, Icons.bar_chart_rounded, 'Dashboard', adminId),
          _buildRailItem(1, Icons.assignment_outlined, 'Complaints', adminId),
          _buildRailItem(2, Icons.admin_panel_settings_outlined, 'Profile', adminId),
        ],
      ),
    );
  }

  Widget _buildRailItem(int index, IconData icon, String label, String adminId) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    Widget iconWidget = Icon(icon, color: color, size: 28);
    
    // Add pending badge if it's complaints tab
    if (index == 1) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            right: -6,
            top: -6,
            child: _buildPendingBadge(adminId),
          ),
        ],
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: iconWidget,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(String adminId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.borderLight, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Stack(
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.bar_chart_rounded)),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.assignment_outlined),
                      Positioned(
                        right: -8,
                        top: -4,
                        child: _buildPendingBadge(adminId),
                      ),
                    ],
                  ),
                ),
                label: 'Complaints',
              ),
              const BottomNavigationBarItem(
                icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.admin_panel_settings_outlined)),
                label: 'Profile',
              ),
            ],
          ),
          // Animated active pill indicator
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: 0,
            left: MediaQuery.sizeOf(context).width / 3 * _currentIndex + (MediaQuery.sizeOf(context).width / 3 - 24) / 2,
            child: Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBadge(String adminId) {
    if (adminId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('complaints')
          .where('adminId', isEqualTo: adminId)
          .where('status', isEqualTo: AppStatuses.pending)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final count = snapshot.data!.docs.length;
        
        if (count == 0) {
          return const SizedBox.shrink(); // Hide if 0
        }

        return AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().scale(begin: const Offset(1.3, 1.3), end: const Offset(1.0, 1.0), duration: 200.ms),
        );
      },
    );
  }

  /// Builds a safe profile avatar with fallback to initials
  Widget _buildProfileAvatar(String? photoUrl, String displayName, double radius) {
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'A';

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          color: Colors.white24,
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => _buildInitialsAvatar(initials, radius),
            placeholder: (context, url) => _buildInitialsAvatar(initials, radius),
          ),
        ),
      );
    }
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: Colors.white24,
      ),
      child: _buildInitialsAvatar(initials, radius),
    );
  }

  Widget _buildInitialsAvatar(String initials, double radius) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          fontSize: radius * 0.6,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
