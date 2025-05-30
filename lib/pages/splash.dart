import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _fadeOut = false;

  @override
  void initState() {
    super.initState();

    // Iniciar desvanecimiento después de 2 segundos
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _fadeOut = true;
      });
    });

    // Navegar a login después de 2.5 segundos
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _fadeOut ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
             transform: GradientRotation(162 * 3.1416 / 180),
             colors: [
              Color.fromRGBO(255, 140, 0, 1),     // Naranja fuerte
              Color.fromRGBO(255, 69, 0, 1),      // Rojo anaranjado
              Color.fromRGBO(255, 0, 0, 1),       // Rojo puro
              Color.fromRGBO(255, 255, 255, 1),   // Blanco
],
stops: [0.0, 0.4, 0.7, 1.0],

            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset(
                    'assets/lumina.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
