import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const String _themeKey = 'appThemeMode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  
  // Note: if it's "system", we let MaterialApp handle it.
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isSystem => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Revert to system tracking when device brightness explicitly changes
    _themeMode = ThemeMode.system;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_themeKey);
    });
    notifyListeners();
    super.didChangePlatformBrightness();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeStr = prefs.getString(_themeKey);
    
    if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> toggleTheme(BuildContext context) async {
    final Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    
    // Determine the current effective theme
    bool isCurrentlyDark = _themeMode == ThemeMode.dark || 
        (_themeMode == ThemeMode.system && systemBrightness == Brightness.dark);
        
    // Toggle explicitly
    _themeMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    
    // Save explicitly
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    
    notifyListeners();
  }
}
