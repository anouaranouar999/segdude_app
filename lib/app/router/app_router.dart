import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/sub_pages/groups.dart';
import 'package:segdude_app/features/auth/presentation/reset_password.dart';
import 'package:segdude_app/features/home/presentation/home_page.dart';
import 'package:segdude_app/features/about/presentation/about_us_page.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/schedule_result_provider.dart';
import 'package:segdude_app/features/auth/presentation/sign_up_page.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/schedule_1st_timing_page.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/schedule_2nd_page.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/sub_pages/add_rooms.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/sub_pages/add_teacher.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/sub_pages/create_subject.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/sub_pages/manual_overrides.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_result/schedule_print_skeleton.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_result/schedule_result_page.dart';
import 'package:segdude_app/features/payment/presentation/buy_page.dart';
import 'package:segdude_app/features/auth/presentation/sign_in_page.dart';
import 'package:segdude_app/features/profile/presentation/profile_page.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Listens to Supabase auth events and notifies GoRouter to refresh routes.
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        // Trigger GoRouter refresh on sign-in, sign-out, or session update
        notifyListeners();
      },
      onError: (error, stack) {
        debugPrint('AuthNotifier stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final AuthNotifier authNotifier = AuthNotifier();

  static final GoRouter router = GoRouter(
    routerNeglect: true,
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/sign_up' ||
          state.matchedLocation == '/reset_password';

      if (loggedIn && isAuthRoute) {
        final from = state.uri.queryParameters['from'];
        return (from != null && from.isNotEmpty) ? from : '/create';
      }

      // `/profile` requires a session. This mirrors the auth-route
      // redirect above (same `from` convention already understood by
      // SignInPage) rather than introducing a separate guard mechanism.
      final isProtectedRoute = state.matchedLocation == '/profile';
      if (!loggedIn && isProtectedRoute) {
        return '/login?from=${state.matchedLocation}';
      }

      return null;
    },
    routes: [
      // ── Auth Routes ────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return SignInPage(from: state.uri.queryParameters['from']);
        },
        routes: [
          GoRoute(
            path: '/reset_password',
            name: 'reset_password',
            builder: (context, state) => const ResetPasswordPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/sign_up',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),

      // ── Landing Home Page ─────────────────────────────────────────────────
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/pricing',
        name: 'pricing',
        builder: (context, state) => const BuyPage(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutUsPage(),
      ),
      // ── Profile (protected by the redirect guard above) ───────────────────
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      // ── Schedule Creation Flow (starts at /create) ────────────────────────
      GoRoute(
        path: '/create',
        name: 'schedule_first_page',
        builder: (context, state) =>
            TimingConstraintsPage(from: state.uri.queryParameters['from']),
        routes: [
          // ------------ Schedule Second Page nested inside /create ------------
          GoRoute(
            path: 'schedule_second_page',
            name: 'schedule_second_page',
            builder: (context, state) => ScheduleCreatePage(),

            routes: [
              // ------------ Route to Create Subject ------------
              GoRoute(
                path: 'create_subject',
                name: 'schedule_create',
                builder: (context, state) => CreateSubject(),
              ),
              // ------------ Route to add teacher ------------
              GoRoute(
                path: 'add_teacher',
                name: 'add_teacher',
                builder: (context, state) => AddTeacher(),
              ),
              // ------------ Route to add room ------------
              GoRoute(
                path: 'add_room',
                name: 'add_room',
                builder: (context, state) => AddRooms(),
              ),
              // ------------ Route to manual overrides ------------
              GoRoute(
                path: 'manual_overrides',
                name: 'manual_overrides',
                builder: (context, state) => const ManualOverridesPage(),
              ),
              // ------------ Route to groups ------------
              GoRoute(
                path: 'groups',
                name: 'groups',
                builder: (context, state) => const Groups(),
              ),
              // ------------ Schedule Result nested inside schedule_second_page --
              GoRoute(
                path: 'result',
                name: 'schedule_result',
                builder: (context, state) {
                  final extra = state.extra;
                  final schedule = extra is ScheduleDecoder
                      ? extra
                      : ProviderScope.containerOf(
                          context,
                        ).read(currentScheduleProvider);

                  return ScheduleResultPage(schedule: schedule);
                },
                // ------------ Sub Routes For Schedule Result ------------
                routes: [
                  GoRoute(
                    path: 'schedule_skeleton',
                    name: 'schedule_skeleton',
                    builder: (context, state) {
                      final extra = state.extra;
                      final schedule = extra is ScheduleDecoder
                          ? extra
                          : ProviderScope.containerOf(
                              context,
                            ).read(currentScheduleProvider);

                      if (schedule != null) {
                        return SchedulePrintSkeleton(schedule: schedule);
                      }

                      return Scaffold(
                        body: Center(
                          child: Text(
                            AppLocalizations.of(context)!.scheduleDataNotFound,
                          ),
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'buy_page',
                    name: 'buy_page',
                    builder: (context, state) => const BuyPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.errorMsg)),
        body: Center(
          child: Text(
            AppLocalizations.of(context)!.routeNotFound(state.uri.toString()),
          ),
        ),
      );
    },
  );
}

class _RedirectToHome extends StatefulWidget {
  @override
  State<_RedirectToHome> createState() => _RedirectToHomeState();
}

class _RedirectToHomeState extends State<_RedirectToHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
