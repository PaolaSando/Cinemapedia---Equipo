import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LocalAuthService {
  // Simulamos un usuario "logueado" en memoria
  bool _isLoggedIn = false;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;

  // Registro de usuario (simulado)
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    // Simulamos una llamada a API/delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoggedIn = true;
    _userEmail = email;
    
    // Navegar al home después del registro exitoso
    if (context.mounted) {
      context.go('/');
    }
  }

  // Inicio de sesión (simulado)
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    // Simulamos una llamada a API/delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    // Validación básica (en una app real, esto vendría de tu backend)
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _userEmail = email;
      
      // Navegar al home después del login exitoso
      if (context.mounted) {
        context.go('/');
      }
    } else {
      _showToast('Por favor ingresa email y contraseña válidos');
    }
  }

  // Cierre de sesión
  Future<void> signout({
    required BuildContext context
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoggedIn = false;
    _userEmail = null;
    
    // Navegar al login después del logout
    if (context.mounted) {
      context.go('/login');
    }
  }

  // Restablecer contraseña (simulado)
  Future<void> resetPassword({
    required String email,
    required BuildContext context
  }) async {
    // Simulamos el envío de email
    await Future.delayed(const Duration(seconds: 2));
    
    _showToast('Se ha enviado un enlace para restablecer tu contraseña a $email');
    
    // Regresar al login después de un tiempo
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      context.pop();
    }
  }

  // Para el AuthWrapper, creamos un stream simulado
  Stream<bool> get authStateChanges async* {
    yield _isLoggedIn;
    // Este stream no emitirá cambios automáticos, pero sirve para la estructura
  }

  void _showToast(String message) {
    // En una app real, usarías fluttertoast o un SnackBar
    print('Auth Message: $message'); // Solo para debug
  }
}