import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/api_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> register() async {
    final result = await ApiService.register(
      emailController.text,
      passwordController.text,
    );

    if (result) {
      Fluttertoast.showToast(msg: "Registration Successful! Check your email.");
      Navigator.pop(context);  // Retour au login après l'inscription
    } else {
      Fluttertoast.showToast(msg: "Registration Failed!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
