import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homecare0x1/constants.dart';
import 'package:homecare0x1/models/user.dart';
import 'package:homecare0x1/user_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to LoginScreen'),
            const SizedBox(height: 10),
            const Text(
              'Sign in with your credentials to access your role-specific dashboard.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                String role = emailController.text.contains('admin')
                    ? 'admin'
                    : emailController.text.contains('caregiver')
                        ? 'caregiver'
                        : 'family';
                userProvider
                    .setUser(User(id: emailController.text, role: role));
                Navigator.pushReplacementNamed(
                    context, userProvider.getInitialRoute());
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
