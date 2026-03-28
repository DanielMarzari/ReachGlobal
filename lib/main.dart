import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'nav.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseService.projectUrl,
    anonKey: SupabaseService.anonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const LighthouseApp(),
    ),
  );
}

class LighthouseApp extends StatelessWidget {
  const LighthouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild router when auth state changes so guards re-evaluate.
    final auth = context.watch<AuthService>();

    return MaterialApp.router(
      title: 'Lighthouse',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.createRouter(auth),
    );
  }
}
