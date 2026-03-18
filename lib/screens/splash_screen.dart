import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _dotController;

  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    
    // Background circles animation
    _circleController = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);

    // Continuous subtle pulse for logo after initial bounce
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Dots loading animation
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _startWorkflow();
  }

  Future<void> _startWorkflow() async {
    // Wait for the logo entrance animation before starting pulse
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      _pulseController.repeat(reverse: true);
    }

    // Minimum display time for brand impression
    await Future.delayed(const Duration(milliseconds: 1800)); // Total 2.5s

    if (mounted) {
      setState(() => _isFadingOut = true);
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        final auth = context.read<AuthProvider>();
        // Wait for auth to finish loading if it hasn't
        while (auth.isLoading) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        if (auth.isAuthenticated) {
          if (mounted) context.go(auth.isAdmin ? '/admin' : '/user/home');
        } else {
          if (mounted) context.go('/login');
        }
      }
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _isFadingOut ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 400),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
              ),
            ),
            // Floating circles
            AnimatedBuilder(
              animation: _circleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _FloatingCirclesPainter(_circleController.value),
                  size: Size.infinite,
                );
              },
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return ScaleTransition(
                        scale: _pulseAnimation,
                        child: Transform.scale(
                          scale: value,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.white24,
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.build_circle_outlined,
                              color: AppColors.primary,
                              size: 48,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // App Name
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: const Text(
                            AppStrings.appName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Tagline
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      // Delayed start
                      final curveValue = Curves.easeOutCubic.transform(
                        (value - 0.3).clamp(0.0, 1.0) / 0.7,
                      );
                      return Opacity(
                        opacity: curveValue,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - curveValue)),
                          child: Text(
                            AppStrings.tagline,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 60),
                  // Loading Indicator
                  AnimatedBuilder(
                    animation: _dotController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;
                          final value =
                              math.sin((_dotController.value * math.pi * 2) - delay);
                          final yOffset = value < 0 ? value * 8 : 0.0;
                          return Transform.translate(
                            offset: Offset(0, yOffset),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Bottom Footer
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: Colors.white.withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
                    Text(
                      'Powered by Google & Firebase',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingCirclesPainter extends CustomPainter {
  final double animationValue;

  _FloatingCirclesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);

    // Circle 1
    final c1x = size.width * 0.2 + (math.sin(animationValue * math.pi * 2) * 50);
    final c1y = size.height * 0.3 + (math.cos(animationValue * math.pi * 2) * 50);
    canvas.drawCircle(Offset(c1x, c1y), size.width * 0.4, paint);

    // Circle 2
    final c2x = size.width * 0.8 + (math.cos(animationValue * math.pi * 2) * 40);
    final c2y = size.height * 0.7 + (math.sin(animationValue * math.pi * 2) * 40);
    canvas.drawCircle(Offset(c2x, c2y), size.width * 0.3, paint);

    // Circle 3
    final paint3 = Paint()..color = Colors.white.withValues(alpha: 0.08);
    final c3x = size.width * 0.5 + (math.sin(animationValue * math.pi) * 60);
    final c3y = size.height * 0.9 + (math.cos(animationValue * math.pi) * 30);
    canvas.drawCircle(Offset(c3x, c3y), size.width * 0.2, paint3);
  }

  @override
  bool shouldRepaint(covariant _FloatingCirclesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
