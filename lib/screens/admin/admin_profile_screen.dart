import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';


// Diagonal line painter for hero texture
class _DiagonalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;
  bool _copied = false;
  Map<String, dynamic>? _adminData;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final authProvider = context.read<AppAuthProvider>();
    final email = authProvider.currentUser?.email;
    if (email == null) return;

    final query = await FirebaseFirestore.instance
        .collection('admins')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        _adminData = query.docs.first.data();
        _nameController.text = _adminData?['name'] ?? '';
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final authProvider = context.read<AppAuthProvider>();
    final email = authProvider.currentUser?.email;

    final query = await FirebaseFirestore.instance
        .collection('admins')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'name': _nameController.text.trim(),
      });
    }

    // Also update via provider so app bar etc. stays in sync
    await authProvider.updateUserName(_nameController.text.trim());

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isEditing = false;
      // Update local data
      _adminData?['name'] = _nameController.text.trim();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Profile updated successfully!', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyAdminId() {
    final adminId = '${_adminData?['adminID'] ?? ''}';
    Clipboard.setData(ClipboardData(text: adminId));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.only(top: 32),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.warning, AppColors.error],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign Out?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'You will be signed out of your admin account and redirected to the login screen.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.error, Color(0xFFDC2626)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      final authProvider = context.read<AppAuthProvider>();
      await authProvider.signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();
    final user = authProvider.currentUser;
    final photoUrl = safePhotoUrl(user);
    final adminName = _adminData?['name'] ?? user?.displayName ?? 'Admin';
    final email = _adminData?['email'] ?? user?.email ?? '';
    final department = _adminData?['department'] ?? '';
    final adminId = '${_adminData?['adminID'] ?? ''}';

    return Scaffold(
      backgroundColor: AppColors.background,

      body: _adminData == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: CustomScrollView(
                  slivers: [
                    // Hero Section
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E3A5F), AppColors.primary],
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: CustomPaint(
                            painter: _DiagonalLinesPainter(),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 32, bottom: 28, left: 24, right: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 1. Avatar
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                    child: _buildProfileAvatar(photoUrl, adminName, 40),
                                  ).animate().scale(begin: const Offset(0.9, 0.9), duration: 400.ms, curve: Curves.easeOutBack),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // 3. Name
                                  Text(
                                    adminName,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  
                                  // 5. Department Row
                                  if (department.isNotEmpty) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.business_outlined, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            department,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                  ] else
                                    const SizedBox(height: 6),
                                  
                                  // 7. Role Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('Administrator', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // 9. Admin ID pill
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: GestureDetector(
                                      onTap: _copyAdminId,
                                      child: AnimatedScale(
                                        scale: _copied ? 1.05 : 1.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _copied ? 'Copied! ' : 'Admin ID: ',
                                                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                              Text(
                                                adminId,
                                                style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700),
                                              ),
                                              const SizedBox(width: 6),
                                              IconButton(
                                                icon: Icon(
                                                  _copied ? Icons.check : Icons.copy_rounded,
                                                  size: 16,
                                                  color: _copied ? AppColors.secondary : AppColors.primary,
                                                ),
                                                onPressed: _copyAdminId,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 36)),

                    // Stats Row
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: StreamBuilder<List<ComplaintModel>>(
                              stream: FirestoreService().streamAdminComplaints(adminId),
                              builder: (context, snapshot) {
                                final complaints = snapshot.data ?? [];
                                final totalCount = complaints.length;
                                final resolvedCount = complaints.where((c) => c.status == AppStatuses.resolved).length;

                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.07),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildStatColumn('Total', totalCount, AppColors.primary),
                                      Container(width: 1, height: 40, color: AppColors.borderLight),
                                      _buildStatColumn('Resolved', resolvedCount, AppColors.secondary),
                                      Container(width: 1, height: 40, color: AppColors.borderLight),
                                      Column(
                                        children: [
                                          const Icon(Icons.business_outlined, color: AppColors.primary, size: 22),
                                          const SizedBox(height: 6),
                                          Text(
                                            department.isNotEmpty ? department : '—',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                          ),
                                          const Text('Department', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.15);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Account Information Card
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.07),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ACCOUNT INFORMATION',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2),
                                  ),
                                  const SizedBox(height: 16),

                                  // Name row
                                  _buildInfoRow(
                                    icon: Icons.person_outline,
                                    label: 'Full Name',
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: _isEditing
                                          ? Row(
                                              key: const ValueKey('edit'),
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: _nameController,
                                                    autofocus: true,
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                                                      border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
                                                    ),
                                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: _isSaving
                                                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                                      : const Icon(Icons.check, color: AppColors.secondary, size: 20),
                                                  onPressed: _isSaving ? null : _saveChanges,
                                                  tooltip: 'Save',
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                                                  onPressed: () {
                                                    _nameController.text = adminName;
                                                    setState(() => _isEditing = false);
                                                  },
                                                  tooltip: 'Cancel',
                                                ),
                                              ],
                                            )
                                          : Text(
                                              key: const ValueKey('display'),
                                              adminName,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                            ),
                                    ),
                                    trailing: _isEditing
                                        ? null
                                        : IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                                            onPressed: () => setState(() => _isEditing = true),
                                            tooltip: 'Edit Name',
                                          ),
                                  ),
                                  const Divider(color: AppColors.borderLight),

                                  // Email row
                                  _buildInfoRow(
                                    icon: Icons.email_outlined,
                                    label: 'Email Address',
                                    child: Text(email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text('Verified', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const Divider(color: AppColors.borderLight),

                                  // Department row
                                  _buildInfoRow(
                                    icon: Icons.business_outlined,
                                    label: 'Department',
                                    child: Text(
                                      department.isNotEmpty ? department : '—',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                    ),
                                    trailing: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                                  ),
                                  const Divider(color: AppColors.borderLight),

                                  // Admin ID row
                                  _buildInfoRow(
                                    icon: Icons.badge_outlined,
                                    label: 'Admin ID',
                                    child: Text(adminId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                    trailing: Tooltip(
                                      message: 'Copy Admin ID',
                                      child: IconButton(
                                        icon: Icon(_copied ? Icons.check : Icons.copy_rounded, size: 18, color: _copied ? AppColors.secondary : AppColors.primary),
                                        onPressed: _copyAdminId,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Security Card
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.07),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SECURITY',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 1.2),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    icon: Icons.g_mobiledata_rounded,
                                    label: 'Google Account',
                                    child: Text(email, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text('Connected', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                  const Divider(color: AppColors.borderLight),
                                  _buildInfoRow(
                                    icon: Icons.schedule,
                                    label: 'Last Active',
                                    child: const Text('Today', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.1),
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Danger Zone Card
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _confirmSignOut,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFFEE2E2)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.error.withValues(alpha: 0.05),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.logout, color: AppColors.error, size: 22),
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Sign Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.error)),
                                            SizedBox(height: 2),
                                            Text('Sign out of your admin account', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: AppColors.error),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideY(begin: 0.1),
                          ),
                        ),
                      ),
                    ),

                    // Version footer
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Text(
                              'FixFlow Admin v1.0.0',
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
                        ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                child,
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Builds a safe profile avatar with fallback to initials
  Widget _buildProfileAvatar(String? photoUrl, String displayName, double radius) {
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'A';

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white24,
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
      backgroundColor: Colors.white24,
      child: _buildInitialsAvatar(initials, radius),
    );
  }

  Widget _buildInitialsAvatar(String initials, double radius) {
    return Icon(
      Icons.admin_panel_settings,
      size: radius,
      color: Colors.white,
    );
  }
}
