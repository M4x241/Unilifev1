import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animaciones
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Inicializar autenticación y navegar
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Esperar a que termine la animación mínima
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      // Inicializar el servicio de autenticación con un timeout general
      await authService.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Timeout en LoadingPage initialize');
          return;
        },
      );
    } catch (e) {
      print('Error en LoadingPage: $e');
    }
    
    // Navegar según el estado de autenticación
    if (mounted) {
      if (authService.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.glowShadow,
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Título
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'UniLife',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Subtítulo
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Tu vida universitaria en una app',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Indicador de carga
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
