import 'package:supabase_flutter/supabase_flutter.dart';

/// Central Supabase client accessor.
/// Call [SupabaseService.client] anywhere in the app after [Supabase.initialize()].
class SupabaseService {
  static const String projectUrl = 'https://sqhpxtfnnupcdgjjhsgc.supabase.co';
  // Publishable (anon) key — safe to ship in client code.
  static const String anonKey =
      'sb_publishable_iJkjw6MSgiyIR10yy3sn3g_x_Kl5bbK';

  static SupabaseClient get client => Supabase.instance.client;

  // ── Convenience getters ─────────────────────────────────────────────────
  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;

  /// The currently authenticated Supabase user (null if not logged in).
  static User? get currentUser => auth.currentUser;

  /// Stream of auth state changes — use in [AuthService] to rebuild the nav.
  static Stream<AuthState> get authStateStream => auth.onAuthStateChange;
}
