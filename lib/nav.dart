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
import 'screens/add_staff_screen.dart';
// Shared
import 'screens/gantt_chart_page.dart';
import 'screens/response_setup_screen.dart';
import 'screens/disaster_dashboard_screen.dart';
import 'screens/worksite_setup_screen.dart';
import 'screens/worksite_detail_screen.dart';

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
  static const String addStaff           = '/staff/add-staff';
  static const String responseSetup      = '/staff/response-setup';
  static const String disasterDashboard  = '/staff/disaster';
  static const String worksiteSetup      = '/staff/worksite-setup';
  static const String worksiteDetail     = '/staff/worksite/:worksiteId';
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

    // Staff/church user landed on the wrong portal (e.g., profile loaded late
    // and they ended up on /volunteer or /). Redirect them to their correct home.
    final isVolunteerRoute = loc.startsWith('/volunteer');
    if (isLoggedIn && isVolunteerRoute && auth.isStaff) {
      return AppRoutes.staffDashboard;
    }
    if (isLoggedIn && isVolunteerRoute && auth.isChurchCoordinator) {
      return AppRoutes.churchDashboard;
    }

    // Staff user somehow landed on the public home — send to staff dashboard.
    if (isLoggedIn && loc == AppRoutes.home && auth.isStaff) {
      return AppRoutes.staffDashboard;
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
    GoRoute(
      path: AppRoutes.addStaff,
      name: 'addStaff',
      pageBuilder: (c, s) =>
          const MaterialPage(child: AddStaffScreen()),
    ),
    GoRoute(
      path: AppRoutes.responseSetup,
      name: 'responseSetup',
      pageBuilder: (c, s) {
        final extra = s.extra as Map<String, dynamic>? ?? {};
        return MaterialPage(
          child: ResponseSetupScreen(
            disasterId:   extra['disasterId']   as String? ?? '',
            disasterName: extra['disasterName'] as String? ?? 'Response',
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.disasterDashboard,
      name: 'disasterDashboard',
      pageBuilder: (c, s) {
        final extra = s.extra as Map<String, dynamic>? ?? {};
        return MaterialPage(
          child: DisasterDashboardScreen(
            disasterId:   extra['disasterId']   as String? ?? '',
            disasterName: extra['disasterName'] as String? ?? 'Response',
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.worksiteSetup,
      name: 'worksiteSetup',
      pageBuilder: (c, s) {
        final extra = s.extra as Map<String, dynamic>? ?? {};
        return MaterialPage(
          child: WorksiteSetupScreen(
            disasterId:   extra['disasterId']   as String? ?? '',
            disasterName: extra['disasterName'] as String? ?? 'Response',
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.worksiteDetail,
      name: 'worksiteDetail',
      pageBuilder: (c, s) {
        final worksiteId = s.pathParameters['worksiteId'] ?? '';
        return MaterialPage(
          child: WorksiteDetailScreen(worksiteId: worksiteId),
        );
      },
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
