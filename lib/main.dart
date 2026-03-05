import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/providers/theme_provider.dart';
import 'package:delivery_apps/features/home/screen/startup_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProviderScope(
      provider: _themeProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: _themeProvider.themeMode,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        home: const StartupView(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      fontFamily: "Metropolis",
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primaryLight,
        brightness: Brightness.light,
        primary: AppColor.primaryLight,
        surface: AppColor.containerLight,
        onSurface: AppColor.textBodyLight,
      ),
      scaffoldBackgroundColor: AppColor.inputFillLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.containerLight,
        foregroundColor: AppColor.textTitleLight,
        elevation: 0,
      ),
      cardColor: AppColor.containerLight,
      iconTheme: IconThemeData(color: AppColor.textBodyLight),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.secondaryBackgroundLight,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColor.primaryLight
              : Colors.grey.shade400,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColor.primaryLight.withValues(alpha: 0.4)
              : Colors.grey.shade300,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      fontFamily: "Metropolis",
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primaryDark,
        brightness: Brightness.dark,
        primary: AppColor.primaryDark,
        surface: AppColor.containerDark,
        onSurface: AppColor.textBodyDark,
      ),
      scaffoldBackgroundColor: AppColor.inputFillDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.containerDark,
        foregroundColor: AppColor.textTitleDark,
        elevation: 0,
      ),
      cardColor: AppColor.containerDark,
      iconTheme: IconThemeData(color: AppColor.textBodyDark),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColor.secondaryBackgroundDark,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColor.primaryDark
              : Colors.grey.shade600,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColor.primaryDark.withValues(alpha: 0.4)
              : Colors.grey.shade800,
        ),
      ),
    );
  }
}

class ThemeProviderScope extends InheritedWidget {
  final ThemeProvider provider;

  const ThemeProviderScope({
    super.key,
    required this.provider,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ThemeProviderScope>();
    assert(scope != null, 'No ThemeProviderScope found in context');
    return scope!.provider;
  }

  @override
  bool updateShouldNotify(ThemeProviderScope oldWidget) =>
      provider.themeMode != oldWidget.provider.themeMode;
}
