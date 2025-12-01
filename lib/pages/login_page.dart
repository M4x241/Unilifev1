import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilife/services/auth_service.dart';
import 'package:unilife/theme/app_theme.dart';
import 'package:unilife/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      } else if (mounted) {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authService.errorMessage ?? 'Error al iniciar sesión'),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.glowShadow,
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Título
                    Text(
                      'Bienvenido a UniLife',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión para continuar',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Campo de email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        hintText: 'ejemplo@ucb.edu.bo',
                        prefixIcon: const Icon(
                          Icons.email,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo';
                        }
                        if (!value.contains('@')) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Campo de contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: '••••••••',
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: AppTheme.primaryPurple,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Botón de login
                    Consumer<AuthService>(
                      builder: (context, authService, child) {
                        return SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Iniciar Sesión',
                            onPressed: _handleLogin,
                            isLoading: authService.isLoading,
                            icon: Icons.login,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Texto de ayuda
                    Text(
                      '¿Olvidaste tu contraseña?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryPurple,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
