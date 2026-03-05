import 'package:flutter/material.dart';
import 'UI/home_screen.dart';
import 'data/word_database.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize database - _ensureDatabaseSeeded will handle empty database
    await WordDatabase.instance.database;
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('Error initializing database: $e');
    print('Stack trace: $stackTrace');
    // Try to reset database if initialization fails
    try {
      print('Attempting to reset database...');
      await WordDatabase.instance.resetDatabase();
      runApp(const MyApp());
    } catch (resetError) {
      print('Failed to reset database: $resetError');
      // Still run the app - let it handle the error gracefully
      runApp(const MyApp());
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Ensure database is closed when app is disposed
    _closeDatabase();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App is going to background or closing - ensure data is saved
      _closeDatabase();
    }
  }

  Future<void> _closeDatabase() async {
    try {
      await WordDatabase.instance.close();
      print('Database closed successfully');
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sinama Translator',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
