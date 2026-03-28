import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'services/auth_service.dart';

// ── Screens ──────────────────────────────────────────────────────────────────
// Public
import 'screens/public_home_screen.dart';
import 'screens/disaster_event_overview_screen.dart';
import 'screens/project_detail_public_screen.dart';
import 'screens/donation_flow_screen.dart';
import 'screens/volunteer_registration_screen.dart';
import 'screens/team_join_screen.dart';
// Auth
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
// Volunteer portal
import 'screens/volunteer_dashboard_screen.dart';
import 'screens/volunteer_onboarding_screen.dart';
import 'screens/user_profile_screen.dart';
// Church / Org portal
import 'screens/church_dashboard_screen.dart';
import 'screens/team_roster_screen.dart';
import 'screens/donation_history_screen.dart';
// Staff portal
import 'screens/staff_dashboard_screen.dart';
import 'screens/projects_list_screen.dart';
import 'screens/project_detail_staff_screen.dart';
import 'screens/volunteer_management_screen.dart';
import 'screens/materials_inventory_screen.dart';
import 'screens/financial_management_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/event_management_screen.dart';
// Shared
import 'screens/gantt_chart_page.dart';

// ── Route constants ───────────────────────────────────────────────────────────
class AppRoutes {
  // Public
  static const String home               = '/';
  static const String eventOverview      = '/event';
  static const String projectDetailPublic= '/project-public';
  static const String donationFlow       = '/donate';
  static const String volunteerRegister  = '/volunteer-register';
  static const String teamJoin           = '/team-join';
  // Auth
  static const String login              = '/login';
  static const String register           = '/register';
  // Volunteer portal
  static const String volunteerDashboard = '/volunteer';
  static const String volunteerOnboarding= '/onboarding';
  static const String userProfile        = '/profile';
  // Church portal
  static const String churchDashboard    = '/church';
  static const String teamRoster         = '/church/team';
  static const String donationHistory    = '/donations/history';
  // Staff portal
  static const String staffDashboard     = '/staff';
  static const String staffProjects      = '/staff/projects';
  static const String projectDetailStaff = '/project-staff';
  static const String staffVolunteers    = '/staff/volunteers';
  static const String staffMaterials     = '/staff/materials';
  static const String staffFinancial     = '/staff/financial';
  static const String staffReports       = '/staff/reports';
  static const String staffEvent         = '/staff/event';
  // Shared
  static const String ganttChart         = '/gantt';
}

// ── Router factory ────────────────────────────────────────────────────────────
class AppRouter {
  /// Call [createRouter] from main.dart, passing the current [AuthService]
  /// so go_router's redirect logic stays in sync with auth state.
  static GoRouter createRouter(AuthService auth) {
    return GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: auth,
      redirect: (context, state) => _guard(auth, state),
      routes: _routes,
    );
  }

  // ── Auth guard ──────────────────────────────────────────────────────────
  static String? _guard(AuthService auth, GoRouterState state) {
    final loc = state.matchedLocation;
    final isLoggedIn = auth.isAuthenticated;

    // Paths that require no authentication.
    const publicPaths = {
      AppRoutes.home,
      AppRoutes.eventOverview,
      AppRoutes.projectDetailPublic,
      AppRoutes.donationFlow,
      AppRoutes.volunteerRegister,
      AppRoutes.teamJoin,
      AppRoutes.login,
      AppRoutes.register,
    };

    final isPublic = publicPaths.contains(loc) ||
        loc.startsWith(AppRoutes.eventOverview) ||
        loc.startsWith(AppRoutes.projectDetailPublic);

    // Unauthenticated user hits a protected route → send to login.
    if (!isLoggedIn && !isPublic) {
      return AppRoutes.login;
    }

    // Authenticated user hits login/register → send to their home.
    if (isLoggedIn &&
        (loc == AppRoutes.login || loc == AppRoutes.register)) {
      return auth.homeRoute;
    }

    // Staff-only routes: redirect non-staff to their dashboard.
    final isStaffRoute = loc.startsWith('/staff');
    if (isLoggedIn && isStaffRoute && !auth.isStaff) {
      return auth.homeRoute;
    }

    // Church-only routes.
    final isChurchRoute = loc.startsWith('/church');
    if (isLoggedIn && isChurchRoute && !auth.isChurchCoordinator && !auth.isStaff) {
      return auth.homeRoute;
    }

    return null; // No redirect needed.
  }

  // ── Route definitions ───────────────────────────────────────────────────
  static final List<RouteBase> _routes = [
    // ── Public ──────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: PublicHomeScreen()),
    ),
    GoRoute(
      path: AppRoutes.eventOverview,
      name: 'eventOverview',
      pageBuilder: (c, s) =>
          const MaterialPage(child: DisasterEventOverviewScreen()),
    ),
    GoRoute(
      path: AppRoutes.projectDetailPublic,
      name: 'projectDetailPublic',
      pageBuilder: (c, s) =>
          const MaterialPage(child: ProjectDetailPublicScreen()),
    ),
    GoRoute(
      path: AppRoutes.donationFlow,
      name: 'donationFlow',
      pageBuilder: (c, s) =>
          const MaterialPage(child: DonationFlowScreen()),
    ),
    GoRoute(
      path: AppRoutes.volunteerRegister,
      name: 'volunteerRegister',
      pageBuilder: (c, s) =>
          const MaterialPage(child: VolunteerRegistrationScreen()),
    ),
    GoRoute(
      path: AppRoutes.teamJoin,
      name: 'teamJoin',
      pageBuilder: (c, s) =>
          const MaterialPage(child: TeamJoinScreen()),
    ),

    // ── Auth ─────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: LoginScreen()),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      pageBuilder: (c, s) =>
          const MaterialPage(child: RegisterScreen()),
    ),

    // ── Volunteer portal ──────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.volunteerDashboard,
      name: 'volunteerDashboard',
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: VolunteerDashboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.volunteerOnboarding,
      name: 'volunteerOnboarding',
      pageBuilder: (c, s) =>
          const MaterialPage(child: VolunteerOnboardingScreen()),
    ),
    GoRoute(
      path: AppRoutes.userProfile,
      name: 'userProfile',
      pageBuilder: (c, s) =>
          const MaterialPage(child: UserProfileScreen()),
    ),

    // ── Church / Org portal ────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.churchDashboard,
      name: 'churchDashboard',
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: ChurchDashboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.teamRoster,
      name: 'teamRoster',
      pageBuilder: (c, s) =>
          const MaterialPage(child: TeamRosterScreen()),
    ),
    GoRoute(
      path: AppRoutes.donationHistory,
      name: 'donationHistory',
      pageBuilder: (c, s) =>
          const MaterialPage(child: DonationHistoryScreen()),
    ),

    // ── Staff portal ───────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.staffDashboard,
      name: 'staffDashboard',
      pageBuilder: (c, s) =>
          const NoTransitionPage(child: StaffDashboardScreen()),
    ),
    GoRoute(
      path: AppRoutes.staffProjects,
      name: 'staffProjects',
      pageBuilder: (c, s) =>
          const MaterialPage(child: ProjectsListScreen()),
    ),
    GoRoute(
      path: AppRoutes.projectDetailStaff,
      name: 'projectDetailStaff',
      pageBuilder: (c, s) =>
          const MaterialPage(child: ProjectDetailStaffScreen()),
    ),
    GoRoute(
      path: AppRoutes.staffVolunteers,
      name: 'staffVolunteers',
      pageBuilder: (c, s) =>
          const MaterialPage(child: VolunteerManagementScreen()),
    ),
    GoRoute(
      path: AppRoutes.staffMaterials,
      name: 'staffMaterials',
      pageBuilder: (c, s) =>
          const MaterialPage(child: MaterialsInventoryScreen()),
    ),
    GoRoute(
      path: AppRoutes.staffFinancial,
      name: 'staffFinancial',
      pageBuilder: (c, s) =>
          const MaterialPage(child: FinancialManagementScreen()),
    ),
    GoRoute(
      path: AppRoutes.staffReports,
      name: 'staffReports',
      pageBuilder: (c, s) =>
          const MaterialPage(child: ReportsScreen()),
    ),
    GoRoute(
      path: AppRoutes.staffEvent,
      name: 'staffEvent',
      pageBuilder: (c, s) =>
          const MaterialPage(child: EventManagementScreen()),
    ),

    // ── Shared ─────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.ganttChart,
      name: 'ganttChart',
      pageBuilder: (c, s) =>
          const MaterialPage(child: GanttChartPage()),
    ),
  ];
}
