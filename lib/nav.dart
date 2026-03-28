import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/public_home_screen.dart';
import 'screens/disaster_event_overview_screen.dart';
import 'screens/project_detail_public_screen.dart';
import 'screens/donation_flow_screen.dart';
import 'screens/volunteer_onboarding_screen.dart';
import 'screens/volunteer_dashboard_screen.dart';
import 'screens/staff_dashboard_screen.dart';
import 'screens/project_detail_staff_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/gantt_chart_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: PublicHomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.eventOverview,
        name: 'eventOverview',
        pageBuilder: (context, state) => const MaterialPage(
          child: DisasterEventOverviewScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.projectDetailPublic,
        name: 'projectDetailPublic',
        pageBuilder: (context, state) => const MaterialPage(
          child: ProjectDetailPublicScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.donationFlow,
        name: 'donationFlow',
        pageBuilder: (context, state) => const MaterialPage(
          child: DonationFlowScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.volunteerOnboarding,
        name: 'volunteerOnboarding',
        pageBuilder: (context, state) => const MaterialPage(
          child: VolunteerOnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.volunteerDashboard,
        name: 'volunteerDashboard',
        pageBuilder: (context, state) => const MaterialPage(
          child: VolunteerDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.staffDashboard,
        name: 'staffDashboard',
        pageBuilder: (context, state) => const MaterialPage(
          child: StaffDashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.projectDetailStaff,
        name: 'projectDetailStaff',
        pageBuilder: (context, state) => const MaterialPage(
          child: ProjectDetailStaffScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.userProfile,
        name: 'userProfile',
        pageBuilder: (context, state) => const MaterialPage(
          child: UserProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ganttChart,
        name: 'ganttChart',
        pageBuilder: (context, state) => const MaterialPage(
          child: GanttChartPage(),
        ),
      ),
    ],
  );
}

class AppRoutes {
  static const String home = '/';
  static const String eventOverview = '/event';
  static const String projectDetailPublic = '/project-public';
  static const String donationFlow = '/donate';
  static const String volunteerOnboarding = '/onboarding';
  static const String volunteerDashboard = '/volunteer';
  static const String staffDashboard = '/staff';
  static const String projectDetailStaff = '/project-staff';
  static const String userProfile = '/profile';
  static const String ganttChart = '/gantt';
}
