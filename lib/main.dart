import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/resume_provider.dart';
import 'screens/resume_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResumeProvider(),
      child: MaterialApp(
        title: 'AI Resume Analyzer',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        themeMode: ThemeMode.light,
        home: const ResumeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const seedColor = Color(0xFF2563EB);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        surface: Colors.white,
        background: const Color(0xFFF4F8FF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F8FF),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF4F8FF),
        foregroundColor: Color(0xFF0F172A),
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
    );
  }
}