import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String? errorMessage;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapAuthError(e.code);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapAuthError(e.code);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}