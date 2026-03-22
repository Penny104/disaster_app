import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';

const _prefsKeyUser = 'app_user';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isRegistered = prefs.containsKey(_prefsKeyUser);
  runApp(DisasterApp(isRegistered: isRegistered));
}

class DisasterApp extends StatelessWidget {
  final bool isRegistered;
  const DisasterApp({super.key, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '防災 APP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFFF7F3EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C3D2E),
          brightness: Brightness.light,
          surface: const Color(0xFFF7F3EC),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFEFDF9),
          foregroundColor: Color(0xFF3D2C1E),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF3D2C1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFEFDF9),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        dividerColor: const Color(0xFFE8E0D5),
      ),
      home: isRegistered ? const HomeScreen() : const RegisterScreen(),
    );
  }
}
