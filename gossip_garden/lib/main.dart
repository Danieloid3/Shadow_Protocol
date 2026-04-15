import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/plants/presentation/screens/main_screen.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  print('=== GOSSIP GARDEN STARTING ===');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    print('Flutter binding initialized');
    runApp(const ProviderScope(child: MyApp()));
    print('App started successfully');
  } catch (e, stack) {
    print('FATAL ERROR in main(): $e');
    print('Stack trace: $stack');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('MyApp building');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFCF8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6741),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFDFCF8),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF4A6741)),
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A6741),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
