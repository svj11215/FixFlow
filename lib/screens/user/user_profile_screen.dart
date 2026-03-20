import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../utils/constants.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AppAuthProvider>();
      if (authProvider.userModel != null) {
        _nameController.text = authProvider.userModel!.name;
      } else if (authProvider.currentUser != null) {
        _nameController.text = authProvider.currentUser!.displayName ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(AppAuthProvider authProvider) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == authProvider.userModel?.name) {
      setState(() => _isEditingName = false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await authProvider.updateUserName(newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isEditingName = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmSignOut(AppAuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sign Out',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of FixFlow?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await authProvider.signOut();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AppAuthProvider>(
        builder: (context, authProvider, _) {
          final userModel = authProvider.userModel;
          final firebaseUser = authProvider.currentUser;

          if (userModel == null && firebaseUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayName = userModel?.name ?? firebaseUser?.displayName ?? 'User';
          final email = userModel?.email ?? firebaseUser?.email ?? 'No email';
          final photoUrl = safePhotoUrl(firebaseUser);

          return CustomScrollView(
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 60, bottom: 80, left: 20, right: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: _buildProfileAvatar(photoUrl, displayName, 50),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.03, 1.03), duration: 2.seconds, curve: Curves.easeInOut),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                          
                          const SizedBox(height: 8),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  'FixFlow Member',
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2),
                        ],
                      ),
                    ),

                    // Stats overlapping card
                    Positioned(
                      bottom: -40,
                      left: 20,
                      right: 20,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: StreamBuilder<List<ComplaintModel>>(
                            stream: context.read<ComplaintProvider>().userComplaints(firebaseUser!.uid),
                            builder: (context, snapshot) {
                              final complaints = snapshot.data ?? [];
                              final total = complaints.length;
                              final resolved = complaints.where((c) => c.status == AppStatuses.resolved).length;
                              final pending = complaints.where((c) => c.status == AppStatuses.pending || c.status == AppStatuses.inProgress).length;

                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatColumn('Total', total, AppColors.primary),
                                    Container(width: 1, height: 40, color: AppColors.borderLight),
                                    _buildStatColumn('Resolved', resolved, AppColors.secondary),
                                    Container(width: 1, height: 40, color: AppColors.borderLight),
                                    _buildStatColumn('Pending', pending, AppColors.warning),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 70)),

              // Content Section
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Email (Read-only)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.email_outlined, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Email Address', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                            const SizedBox(height: 4),
                                            Text(email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, color: AppColors.borderLight),
                                
                                // Name (Editable)
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.badge_outlined, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Full Name', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                            const SizedBox(height: 4),
                                            AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 300),
                                              child: _isEditingName
                                                  ? TextField(
                                                      controller: _nameController,
                                                      decoration: const InputDecoration(
                                                        isDense: true,
                                                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                                        border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                                                      ),
                                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                                      autofocus: true,
                                                    )
                                                  : Text(
                                                      displayName,
                                                      key: const ValueKey('name_text'),
                                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(_isEditingName ? Icons.close : Icons.edit_outlined),
                                        color: AppColors.textSecondary,
                                        onPressed: () {
                                          setState(() {
                                            if (_isEditingName) {
                                              _nameController.text = displayName; // revert
                                            }
                                            _isEditingName = !_isEditingName;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // Save Changes Button
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: _isEditingName ? 60 : 0,
                                  curve: Curves.easeInOut,
                                  child: ClipRect(
                                    child: Align(
                                      alignment: Alignment.center,
                                      heightFactor: _isEditingName ? 1.0 : 0.0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 40,
                                          child: ElevatedButton(
                                            onPressed: _isSaving ? null : () => _saveChanges(authProvider),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              elevation: 0,
                                            ),
                                            child: _isSaving
                                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1),

                          const SizedBox(height: 32),

                          // Sign Out Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () => _confirmSignOut(authProvider),
                              icon: const Icon(Icons.logout, color: AppColors.error),
                              label: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1),

                          const SizedBox(height: 32),
                          
                          // Version Note
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'FixFlow Version 1.0.0',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Made by SJ',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: count),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds a safe profile avatar with fallback to initials
  Widget _buildProfileAvatar(String? photoUrl, String displayName, double radius) {
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
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
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: _buildInitialsAvatar(initials, radius),
    );
  }

  Widget _buildInitialsAvatar(String initials, double radius) {
    return Icon(
      Icons.person,
      size: radius,
      color: AppColors.primary,
    );
  }
}
