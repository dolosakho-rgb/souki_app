import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://mlazwwlruoccaranuslc.supabase.co',
    publishableKey: 'sb_publishable_Z7HVOBwtLdLSYGa3Wor53Q_Zxy2JlCO',
  );
  runApp(const SoukiApp());
}

class SoukiApp extends StatelessWidget {
  const SoukiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOUKI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
