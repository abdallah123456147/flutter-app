import 'package:bennasafi/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bennasafi/services/auth_service.dart';
import 'package:bennasafi/screens/firstpage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://crhyqjbhwrnbbhmdlhch.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyaHlxamJod3JuYmJobWRsaGNoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MjQwNjcsImV4cCI6MjA3MzUwMDA2N30.yBO8i2q0xtgAmcLMnyp6rQVzdDH8tgkdl7wLkEJEJDI',
  );
  //remove rotation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  bool _isCheckingConnection = true;
  bool _isFirstOpen = true; // Add this variable

  @override
  void initState() {
    super.initState();
    _checkFirstOpen();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Check if this is the first time the app is opened
  Future<void> _checkFirstOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstOpen = prefs.getBool('isFirstOpen') ?? true;

    setState(() {
      _isFirstOpen = isFirstOpen;
    });

    // If it's the first open, mark it as not first open for next time
    if (isFirstOpen) {
      await prefs.setBool('isFirstOpen', false);
    }
  }

  Future<void> _initConnectivity() async {
    setState(() {
      _isCheckingConnection = true;
    });

    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print("Impossible de vérifier l'état de la connectivité : $e");
      return;
    }

    if (!mounted) {
      return;
    }

    await _updateConnectionStatus(result);

    setState(() {
      _isCheckingConnection = false;
    });
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  bool get hasConnection {
    return _connectionStatus.contains(ConnectivityResult.wifi) ||
        _connectionStatus.contains(ConnectivityResult.mobile);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService()..init(),
      child: MaterialApp(
        builder: (context, child) {
          return SafeArea(top: false, bottom: true, child: child!);
        },
        title: 'BennaSafi',
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        home: _buildHomeScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (_isCheckingConnection) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                'Vérification de la connexion...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    } else if (!hasConnection) {
      // Show no internet screen
      return NoInternetScreen(
        onRetry: () {
          _initConnectivity();
        },
      );
    } else {
      // Show splash screen only on first open
      if (_isFirstOpen && _showSplash) {
        return SplashScreen(
          onAnimationComplete: () {
            setState(() {
              _showSplash = false;
            });
          },
        );
      } else {
        return Firstpage();
      }
    }
  }
}

// No Internet Screen Widget
class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetScreen({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 80, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              'Pas de connexion Internet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Veuillez vérifier votre connexion et réessayer',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
