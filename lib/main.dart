import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv_package;
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/providers/app_provider.dart';
import 'package:uptop_careers/providers/auth_provider.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:uptop_careers/providers/program_provider.dart';
import 'package:uptop_careers/providers/wallet_provider.dart';
import 'package:uptop_careers/providers/game_provider.dart';
import 'package:uptop_careers/providers/leaderboard_provider.dart';
import 'package:uptop_careers/providers/application_provider.dart';
import 'package:uptop_careers/providers/payment_provider.dart';
import 'package:uptop_careers/screens/splash_screen.dart';
import 'package:uptop_careers/services/supabase_service.dart';
import 'package:uptop_careers/services/deep_link_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  try {
    await dotenv_package.dotenv.load(fileName: ".env");
    debugPrint('✅ .env file loaded successfully');
  } catch (e) {
    // If .env file doesn't exist or is empty, continue without it
    // The app will use compiled environment config
    debugPrint('⚠️ .env file not found. Using compiled environment config.');
  }

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
  } catch (e, stackTrace) {
    debugPrint('⚠️ Supabase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue without Supabase - app will work in offline mode
  }

  // Initialize Deep Link Service
  try {
    await DeepLinkService().initialize();
    debugPrint('✅ Deep link service initialized');
  } catch (e, stackTrace) {
    debugPrint('⚠️ Deep link service initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue without deep links
  }

  // Run the app with error handling
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProgramProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'Uptop Careers',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
