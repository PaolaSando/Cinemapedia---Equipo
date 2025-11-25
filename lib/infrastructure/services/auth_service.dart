import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Registro de usuario
  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password
      );

      _showToast('Cuenta creada exitosamente');
      
      // Navegar al home después del registro exitoso
      if (context.mounted) {
        context.go('/');
      }
      
    } on FirebaseAuthException catch(e) {
      String message = 'Error al crear la cuenta';
      
      switch (e.code) {
        case 'weak-password':
          message = 'La contraseña es demasiado débil.';
          break;
        case 'email-already-in-use':
          message = 'Ya existe una cuenta con este correo electrónico.';
          break;
        case 'invalid-email':
          message = 'El correo electrónico no es válido.';
          break;
        case 'operation-not-allowed':
          message = 'La operación no está permitida.';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      
      _showToast(message);
    } catch(e) {
      _showToast('Error inesperado: $e');
    }
  }

  // Inicio de sesión
  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password
      );

      _showToast('Sesión iniciada exitosamente');
      
      // Navegar al home después del login exitoso
      if (context.mounted) {
        context.go('/');
      }
      
    } on FirebaseAuthException catch(e) {
      String message = 'Error al iniciar sesión';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'No existe una cuenta con este correo electrónico.';
          break;
        case 'wrong-password':
          message = 'La contraseña es incorrecta.';
          break;
        case 'invalid-email':
          message = 'El correo electrónico no es válido.';
          break;
        case 'user-disabled':
          message = 'Esta cuenta ha sido deshabilitada.';
          break;
        case 'invalid-credential':
          message = 'Credenciales inválidas.';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      
      _showToast(message);
    } catch(e) {
      _showToast('Error inesperado: $e');
    }
  }

  // Cierre de sesión
  Future<void> signout({
    required BuildContext context
  }) async {
    try {
      await _auth.signOut();
      _showToast('Sesión cerrada');
      
      // Navegar al login después del logout
      if (context.mounted) {
        context.go('/login');
      }
    } catch(e) {
      _showToast('Error al cerrar sesión: $e');
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword({
    required String email,
    required BuildContext context
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _showToast('Se ha enviado un enlace para restablecer tu contraseña');
      
    } on FirebaseAuthException catch(e) {
      String message = 'Error al enviar el correo de restablecimiento';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'No existe una cuenta con este correo electrónico.';
          break;
        case 'invalid-email':
          message = 'El correo electrónico no es válido.';
          break;
        default:
          message = 'Error: ${e.message}';
      }
      
      _showToast(message);
    } catch(e) {
      _showToast('Error inesperado: $e');
    }
  }

  // Mostrar notificaciones toast
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}