import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'signup_screen.dart';
import 'upload_image.dart';
import 'forgot_password_screen.dart';
import '../utils/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final result = await ApiService.login(
      emailController.text,
      passwordController.text,
    );

    if (result != null) {
      Fluttertoast.showToast(msg: "Connexion réussie !");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UploadImageScreen(token: result),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Échec de la connexion !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connexion")),
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
              decoration: InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text("Connexion"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                );
              },
              child: Text("Mot de passe oublié ?"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text("Pas encore de compte ? Inscrivez-vous"),
            ),
          ],
        ),
      ),
    );
  }
}
