import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pslab/providers/board_state_provider.dart';
import 'package:pslab/providers/locator.dart';
import 'package:pslab/view/Theme/theme.dart';
import 'package:pslab/view/connect_device_screen.dart';
import 'package:pslab/view/faq_screen.dart';
import 'package:pslab/view/instruments_screen.dart';
import 'package:pslab/view/oscilloscope_screen.dart';
import 'package:pslab/view/settings_screen.dart';
import 'package:pslab/view/about_us_screen.dart';
import 'package:pslab/view/software_licenses_screen.dart';
import 'package:pslab/providers/theme_provider.dart';
import 'constants.dart';

Future<void> main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  getIt<BoardStateProvider>().initialize();
  final themeProvider = getIt<ThemeProvider>();
  await themeProvider.loadThemeMode();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BoardStateProvider>(
          create: (context) => getIt<BoardStateProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => getIt<ThemeProvider>(),
          child: const MyApp(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _preCacheImages(context);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const InstrumentsScreen(),
            '/oscilloscope': (context) => const OscilloscopeScreen(),
            '/connectDevice': (context) => const ConnectDeviceScreen(),
            '/faq': (context) => const FAQScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/aboutUs': (context) => const AboutUsScreen(),
            '/softwareLicenses': (context) => const SoftwareLicensesScreen(),
          },
        );
      },
    );
  }
}

void _preCacheImages(BuildContext context) {
  for (final path in instrumentIcons) {
    precacheImage(AssetImage(path), context);
  }
  precacheImage(
      const AssetImage('assets/icons/ic_nav_header_logo.png'), context);
}
