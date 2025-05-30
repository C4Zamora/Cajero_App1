import 'package:cajero_app/pages/dashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'pages/splash.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDrfJuxOQsY901u16nQhHy6PTTXK_LifUM",
        appId: "1:371442000945:android:5764959e912a0c2c682110",
        messagingSenderId: "371442000945",
        projectId: "cajeroapp-f5a48",
        storageBucket: "cajeroapp-f5a48.firebasestorage.ap",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Cajero',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');

        if (uri.path == '/') {
          return MaterialPageRoute(builder: (_) => SplashScreen());
        }
         if (uri.path == '/login') {
          return MaterialPageRoute(builder: (_) => LoginPage());
        }
         
        if (uri.path == '/registro') {
          return MaterialPageRoute(builder: (_) => RegisterPage());
        }
        if (uri.path == '/dashboard') {
          return MaterialPageRoute(builder: (_) => DashboardPage());
        }
    
      },
      builder: (context, child) {
        return TooltipTheme(
          data: TooltipThemeData(
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: const TextStyle(color: Colors.white),
          ),
          child: child!,
        );
      },
    );
  }
}
