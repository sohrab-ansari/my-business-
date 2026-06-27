import 'package:flutter/material.dart';
import 'package:mybusiness/utils/utils_helper.dart';
import 'package:mybusiness/viewmodels/auth_viewmidel.dart';
import 'package:provider/provider.dart';

import 'auth/login_screen.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v!.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password (min 6 chars)'),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: 24),
                if (authVM.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await authVM.register(_emailController.text, _passwordController.text);
                          if (context.mounted) {
                            UiHelpers.showSnackBar(context, 'Registration successful! Please login.');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          }
                        } catch (e) {
                          UiHelpers.showSnackBar(context, authVM.errorMessage!, isError: true);
                        }
                      }
                    },
                    child: const Text('Register'),
                  ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}