import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/about_screen.dart';
import 'screens/user/user_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

class FixFlowApp extends StatelessWidget {
  const FixFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();

    final router = GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (state.uri.path == '/admin/dashboard') return '/admin';
        if (state.uri.path == '/admin/profile') return '/admin';

        final isAuthenticated = authProvider.isAuthenticated;
        final isLoading = authProvider.isLoading;
        final isSplashRoute = state.matchedLocation == '/';
        final isLoginRoute = state.matchedLocation == '/login';

        if (isSplashRoute) return null; // Let splash screen handle the delay

        if (isLoading) return null;

        if (!isAuthenticated && !isLoginRoute) return '/login';
        if (isAuthenticated && isLoginRoute) {
          return authProvider.isAdmin ? '/admin' : '/user/home';
        }

        // Guard admin routes
        if (state.matchedLocation.startsWith('/admin') &&
            !authProvider.isAdmin) {
          return '/user/home';
        }

        // Guard user routes
        if (state.matchedLocation.startsWith('/user') &&
            authProvider.isAdmin) {
          return '/admin';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/user/home',
          builder: (context, state) => const UserHomeScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminHomeScreen(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Page not found', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );

    return MaterialApp.router(
      title: 'FixFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
