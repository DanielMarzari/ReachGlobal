import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// User roles matching the profiles.role column in Supabase.
enum UserRole {
  superAdmin,
  coordinator,
  churchCoordinator,
  volunteer,
  donor,
  unknown,
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.coordinator:
        return 'coordinator';
      case UserRole.churchCoordinator:
        return 'church_coordinator';
      case UserRole.volunteer:
        return 'volunteer';
      case UserRole.donor:
        return 'donor';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  static UserRole fromString(String? s) {
    switch (s) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'coordinator':
        return UserRole.coordinator;
      case 'church_coordinator':
        return UserRole.churchCoordinator;
      case 'volunteer':
        return UserRole.volunteer;
      case 'donor':
        return UserRole.donor;
      default:
        return UserRole.unknown;
    }
  }
}

/// Manages authentication state and exposes role-aware helpers.
/// Provide this via [ChangeNotifierProvider] at the root of the widget tree.
class AuthService extends ChangeNotifier {
  AuthService() {
    // Listen to Supabase auth changes and refresh state.
    SupabaseService.authStateStream.listen((event) {
      _user = event.session?.user;
      _loadProfile();
      notifyListeners();
    });
    _user = SupabaseService.currentUser;
    if (_user != null) _loadProfile();
  }

  User? _user;
  Map<String, dynamic>? _profile;
  bool _profileLoading = false;

  // ── Public getters ────────────────────────────────────────────────────────
  bool get isAuthenticated => _user != null;
  User? get user => _user;
  String? get userId => _user?.id;
  String? get email => _user?.email;

  UserRole get role =>
      UserRoleX.fromString(_profile?['role'] as String?);

  bool get isStaff =>
      role == UserRole.superAdmin || role == UserRole.coordinator;
  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isChurchCoordinator => role == UserRole.churchCoordinator;
  bool get isVolunteer => role == UserRole.volunteer;
  bool get isDonor => role == UserRole.donor;

  String get displayName =>
      (_profile?['full_name'] as String?) ?? email ?? 'User';

  /// Where to route after login based on role.
  String get homeRoute {
    if (!isAuthenticated) return '/login';
    switch (role) {
      case UserRole.superAdmin:
      case UserRole.coordinator:
        return '/staff';
      case UserRole.churchCoordinator:
        return '/church';
      default:
        return '/volunteer';
    }
  }

  // ── Auth operations ───────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    await SupabaseService.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // Wait for profile to load after sign-in to ensure role is available
    await Future.delayed(const Duration(milliseconds: 500));
    while (_profileLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String role = 'volunteer',
  }) async {
    final res = await SupabaseService.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'role': role,
      },
    );
    if (res.user != null) {
      // Profile row is created by a Supabase trigger (see migrations).
      _user = res.user;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
    _profile = null;
    _user = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await SupabaseService.auth.resetPasswordForEmail(email);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<void> _loadProfile() async {
    if (_user == null || _profileLoading) return;
    _profileLoading = true;
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', _user!.id)
          .maybeSingle();
      _profile = data;
      notifyListeners();
    } catch (_) {
      // Profile may not exist yet on first sign-up — ignore.
    } finally {
      _profileLoading = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_user == null) return;
    await SupabaseService.client
        .from('profiles')
        .update(updates)
        .eq('id', _user!.id);
    await _loadProfile();
  }
}
