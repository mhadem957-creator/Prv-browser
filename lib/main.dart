import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/browser_settings.dart';
import 'screens/browser_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PrivacyBrowserApp());
}

class PrivacyBrowserApp extends StatefulWidget {
  const PrivacyBrowserApp({super.key});

  @override
  State<PrivacyBrowserApp> createState() => _PrivacyBrowserAppState();
}

class _PrivacyBrowserAppState extends State<PrivacyBrowserApp> {
  final BrowserSettings _settings = BrowserSettings();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _settings.load().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return ChangeNotifierProvider<BrowserSettings>.value(
      value: _settings,
      child: MaterialApp(
        title: 'Privacy Browser',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const BrowserScreen(),
      ),
    );
  }
}
