import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/api_service.dart';
import 'upload_image.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  OtpScreen({required this.email});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();

  Future<void> verifyOtp() async {
    final otpResult = await ApiService.verifyOtp(
      widget.email,
      otpController.text,
    );

    if (otpResult != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP vérifié avec succès.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UploadImageScreen(token: otpResult),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP incorrect ou expiré.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Vérification OTP",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: "Code OTP",
                      hintText: "000000",  // Placeholder "000000"
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,  // Autoriser uniquement les chiffres
                      LengthLimitingTextInputFormatter(6),  // Limite à 6 chiffres
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Vérifier OTP",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
