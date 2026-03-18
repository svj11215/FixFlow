import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userModel;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;
    
    final String fullName = user?.name ?? '';
    final String firstName = fullName.trim().isNotEmpty ? fullName.trim().split(' ')[0] : 'there';
    
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = "Good Morning";
    } else if (hour < 17) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 56.0 : 60.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // LEFT: Logo & Brand
                  Container(
                    width: isMobile ? 26 : 28,
                    height: isMobile ? 26 : 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isMobile ? 7.0 : 8.0),
                    ),
                    child: Icon(Icons.build_rounded, color: const Color(0xFF2563EB), size: isMobile ? 14 : 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FixFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: isMobile ? 16 : 17,
                    ),
                  ),
                  const Spacer(),
                  // RIGHT: Greeting & Avatar
                  if (isMobile) ...[
                    Flexible(
                      child: Text(
                        'Hi, $firstName',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    Text(
                      '$greeting, $firstName',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 12),
                  ],
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 2),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: isMobile ? 1.5 : 2.0),
                      ),
                      child: CircleAvatar(
                        radius: isMobile ? 15 : 16,
                        backgroundColor: Colors.white24,
                        backgroundImage: authProvider.currentUser?.photoURL != null
                            ? NetworkImage(authProvider.currentUser!.photoURL!)
                            : null,
                        child: authProvider.currentUser?.photoURL == null
                            ? Icon(Icons.person, color: Colors.white, size: isMobile ? 16 : 18)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryLight,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 65,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.add_circle, color: AppColors.primary),
              label: 'Submit',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.list_alt, color: AppColors.primary),
              label: 'My Complaints',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
