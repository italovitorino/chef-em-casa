import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/dio_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/domain/auth_state.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'screens/chef_home_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bg,
    ),
  );
  runApp(const ProviderScope(child: ChefEmCasaApp()));
}

class ChefEmCasaApp extends ConsumerStatefulWidget {
  const ChefEmCasaApp({super.key});

  @override
  ConsumerState<ChefEmCasaApp> createState() => _ChefEmCasaAppState();
}

class _ChefEmCasaAppState extends ConsumerState<ChefEmCasaApp> {
  @override
  void initState() {
    super.initState();
    _checkStartupToken();
  }

  Future<void> _checkStartupToken() async {
    final storage = ref.read(tokenStorageProvider);
    final hasToken = await storage.hasToken();
    if (!mounted || !hasToken) return;
    final role = await storage.userRole;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              role == 'CHEF' ? const ChefHomeScreen() : const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sessão expirada via interceptor → acionar logout no provider
    ref.listen<bool>(sessionExpiredProvider, (_, expired) {
      if (expired) {
        ref.read(sessionExpiredProvider.notifier).state = false;
        ref.read(authNotifierProvider.notifier).forceLogout();
      }
    });

    // Logout explícito ou forçado → navegar para WelcomeScreen
    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next is AuthUnauthenticated) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (_) => false,
        );
      }
    });

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Chef em Casa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.terra,
          secondary: AppColors.gold,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        sliderTheme: const SliderThemeData(
          trackHeight: 0,
          overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
