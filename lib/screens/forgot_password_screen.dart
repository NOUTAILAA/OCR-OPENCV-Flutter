import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  Future<void> resetPassword() async {
    final result = await ApiService.forgotPassword(emailController.text);

    if (result) {
      Fluttertoast.showToast(msg: "Un email de réinitialisation a été envoyé.");
      Navigator.pop(context);  // Retour à la page de connexion
    } else {
      Fluttertoast.showToast(msg: "Email non trouvé !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mot de passe oublié")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Entrez votre email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              child: Text("Réinitialiser le mot de passe"),
            ),
          ],
        ),
      ),
    );
  }
}
