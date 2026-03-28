import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lighthouse/supabase/supabase_config.dart';

/// Central Supabase client accessor.
/// Call [SupabaseService.client] anywhere in the app after [Supabase.initialize()].
class SupabaseService {
  static const String projectUrl = SupabaseConfig.supabaseUrl;
  static const String anonKey = SupabaseConfig.anonKey;

  static SupabaseClient get client => SupabaseConfig.client;

  // ── Convenience getters ─────────────────────────────────────────────────
  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;

  /// The currently authenticated Supabase user (null if not logged in).
  static User? get currentUser => auth.currentUser;

  /// Stream of auth state changes — use in [AuthService] to rebuild the nav.
  static Stream<AuthState> get authStateStream => auth.onAuthStateChange;
}
