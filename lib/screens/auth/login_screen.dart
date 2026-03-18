import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // To handle hover effects
  bool _isAdminHovered = false;
  bool _isUserHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient & Wave
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  flex: 45,
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.gradientStart, AppColors.gradientEnd],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -1, // prevent seam gap
                        left: 0,
                        right: 0,
                        child: CustomPaint(
                          size: const Size(double.infinity, 80),
                          painter: _WavePainter(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 55,
                  child: Container(color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Content
          SafeArea(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          
                          // Top Section
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 16,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.build_circle_outlined,
                                  color: AppColors.primary,
                                  size: 44,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                AppStrings.appName,
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.tagline,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ]
                                .animate(interval: 80.ms)
                                .fade(duration: 400.ms)
                                .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                          ),
                          
                          const Spacer(flex: 1),
                          
                          // Bottom Section Card
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 32,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Welcome Back',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Sign in to continue to FixFlow',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      
                                      // Error Message
                                      if (authProvider.error != null)
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 20),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius: BorderRadius.circular(10),
                                            border: const Border(
                                              left: BorderSide(color: AppColors.error, width: 3),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.error_outline,
                                                  color: AppColors.error, size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  authProvider.error!,
                                                  style: const TextStyle(
                                                    color: AppColors.error,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => authProvider.clearError(),
                                                child: const Icon(Icons.close,
                                                    color: AppColors.error, size: 16),
                                              ),
                                            ],
                                          ),
                                        ).animate().slideY(begin: -0.1, duration: 300.ms).fade(),
                                      
                                      // User Button
                                      MouseRegion(
                                        onEnter: (_) => setState(() => _isUserHovered = true),
                                        onExit: (_) => setState(() => _isUserHovered = false),
                                        child: AnimatedScale(
                                          scale: authProvider.isLoading ? 0.97 : (_isUserHovered ? 1.02 : 1.0),
                                          duration: const Duration(milliseconds: 100),
                                          child: Container(
                                            width: double.infinity,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: _isUserHovered
                                                  ? [const BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))]
                                                  : [],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: authProvider.isLoading
                                                  ? null
                                                  : () => _signInAsUser(context, authProvider),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  if (authProvider.isLoading && authProvider.role == 'user')
                                                    const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                    )
                                                  else ...[
                                                    const Icon(Icons.person_outline, size: 20, color: Colors.white),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                      'Continue as User',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        letterSpacing: 0.3,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Divider
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        child: Row(
                                          children: [
                                            Expanded(child: Divider(color: AppColors.borderLight)),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                'or',
                                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                              ),
                                            ),
                                            Expanded(child: Divider(color: AppColors.borderLight)),
                                          ],
                                        ),
                                      ),
                                      
                                      // Admin Button
                                      MouseRegion(
                                        onEnter: (_) => setState(() => _isAdminHovered = true),
                                        onExit: (_) => setState(() => _isAdminHovered = false),
                                        child: AnimatedScale(
                                          scale: authProvider.isLoading ? 0.97 : (_isAdminHovered ? 1.02 : 1.0),
                                          duration: const Duration(milliseconds: 100),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: double.infinity,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: _isAdminHovered ? AppColors.primaryLight : Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _isAdminHovered ? AppColors.primary : AppColors.borderLight,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(12),
                                              onTap: authProvider.isLoading
                                                  ? null
                                                  : () => _signInAsAdmin(context, authProvider),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    if (authProvider.isLoading && authProvider.role == 'admin')
                                                      const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                                      )
                                                    else ...[
                                                      const Icon(Icons.shield_outlined,
                                                          size: 20, color: AppColors.primary),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        'Continue as Admin',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w600,
                                                          letterSpacing: 0.3,
                                                          color: AppColors.textPrimary,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.verified_user_outlined,
                                              size: 14, color: AppColors.textMuted),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Protected by Google Authentication',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]
                                        .animate(interval: 80.ms)
                                        .fade(duration: 400.ms)
                                        .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic).fade(),
                          
                          const Spacer(flex: 2),
                          
                          // Footer
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock_outline,
                                    size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                const Text(
                                  'Powered by Google & Firebase',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fade(delay: 600.ms),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInAsUser(
      BuildContext context, AuthProvider authProvider) async {
    await authProvider.signInAsUser();
  }

  Future<void> _signInAsAdmin(
      BuildContext context, AuthProvider authProvider) async {
    await authProvider.signInAsAdmin();
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.4);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.5,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.4,
    );

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
