// [UPGRADE] user-home-theme | Theme-aware nav + AppBar | original: hardcoded colors | revert: restore old user_home_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import 'chat_screen.dart';
import 'my_complaints_screen.dart';
import 'submit_complaint_screen.dart';
import 'user_profile_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SubmitComplaintScreen(),
    const MyComplaintsScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final user = authProvider.userModel;
    final isDark = AppTheme.isDark(context);
    final cardColor = Theme.of(context).cardColor;

    final String fullName = user?.name ?? '';
    final String firstName = fullName.trim().isNotEmpty ? fullName.trim().split(' ')[0] : 'there';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              'Hi, $firstName',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 2),
              child: _buildProfileAvatar(
                safePhotoUrl(authProvider.currentUser),
                firstName,
                16,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _pages[_selectedIndex],
      ),
      // [UPGRADE] theme-aware | Bottom nav colors from theme | original: Colors.white | revert: hardcode Colors.white
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          backgroundColor: cardColor,
          indicatorColor: AppTheme.primaryLightColor(context),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 65,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, color: AppTheme.textSecondary(context)),
              selectedIcon: Icon(Icons.add_circle, color: AppTheme.primaryColor(context)),
              label: 'Submit',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined, color: AppTheme.textSecondary(context)),
              selectedIcon: Icon(Icons.list_alt, color: AppTheme.primaryColor(context)),
              label: 'My Complaints',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppTheme.textSecondary(context)),
              selectedIcon: Icon(Icons.person, color: AppTheme.primaryColor(context)),
              label: 'Profile',
            ),
          ],
        ),
      ),
      // [UPGRADE] gemini-chat | Floating AI chat button | revert: remove floatingActionButton
      floatingActionButton: _buildChatFab(context),
    );
  }

  Widget _buildChatFab(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'chat_fab',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 26),
      ),
    )
        .animate()
        .scale(
          delay: 400.ms,
          duration: 500.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(delay: 400.ms, duration: 300.ms);
  }

  Widget _buildProfileAvatar(String? photoUrl, String displayName, double radius) {
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';

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
