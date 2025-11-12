import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/services/supabase_service.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/signup_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/morning_contract/morning_contract_screen.dart';
import '../ui/screens/capture_proof/capture_proof_screen.dart';
import '../ui/screens/sync_20h/sync_screen.dart';
import '../ui/screens/victory_feed/victory_feed_screen.dart';
import '../ui/screens/profile_sablier/profile_screen.dart';
import '../ui/screens/phoenix_mode/phoenix_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home', // DEMO MODE: Start directly at home
    redirect: (context, state) {
      // DEMO MODE: Disable authentication check
      // Uncomment lines below when Supabase is configured
      /*
      final isAuthenticated = SupabaseService.isAuthenticated;
      final isAuthRoute = state.uri.path.startsWith('/login') ||
                          state.uri.path.startsWith('/signup');

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }
      */

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/morning-contract',
        builder: (context, state) => const MorningContractScreen(),
      ),
      GoRoute(
        path: '/capture-proof/:dailyGoalId',
        builder: (context, state) {
          final dailyGoalId = state.pathParameters['dailyGoalId']!;
          return CaptureProofScreen(dailyGoalId: dailyGoalId);
        },
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => const SyncScreen(),
      ),
      GoRoute(
        path: '/feed',
        builder: (context, state) => const VictoryFeedScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/phoenix',
        builder: (context, state) => const PhoenixScreen(),
      ),
    ],
  );
});
