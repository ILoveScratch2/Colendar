import 'package:go_router/go_router.dart';

import '../providers/settings_provider.dart';
import '../screens/main/main_screen.dart';
import '../screens/course/course_edit_screen.dart';
import '../screens/course/course_detail_screen.dart';
import '../screens/course/course_list_screen.dart';
import '../screens/settings/semester_management_screen.dart';
import '../screens/settings/class_time_config_screen.dart';
import '../screens/settings/timetable_settings_screen.dart';
import '../screens/adjustment/adjustment_management_screen.dart';
import '../screens/import/batch_course_create_screen.dart';
import '../screens/welcome/onboarding_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'app_shell.dart';

GoRouter buildRouter(SettingsProvider settings) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: settings,
    redirect: (context, state) {
      // First-time onboarding
      if (!settings.onboardingDone && state.uri.toString() != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const MainScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Standalone routes (no bottom nav)
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/semester',
        builder: (_, __) => const SemesterManagementScreen(),
      ),
      GoRoute(
        path: '/courses',
        builder: (_, __) => const CourseListScreen(),
      ),
      GoRoute(
        path: '/course/new',
        builder: (context, state) {
          final scheduleId =
              int.tryParse(state.uri.queryParameters['scheduleId'] ?? '');
          return CourseEditScreen(scheduleId: scheduleId);
        },
      ),
      GoRoute(
        path: '/course/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CourseDetailScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/course/:id/edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CourseEditScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/adjustments',
        builder: (_, __) => const AdjustmentManagementScreen(),
      ),
      GoRoute(
        path: '/import/batch',
        builder: (_, __) => const BatchCourseCreateScreen(),
      ),
      GoRoute(
        path: '/settings/timetable',
        builder: (_, __) => const TimetableSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/classtimes',
        builder: (_, __) => const ClassTimeConfigScreen(),
      ),
    ],
  );
}
