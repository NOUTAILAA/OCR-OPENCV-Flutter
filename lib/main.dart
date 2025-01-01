import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Login & Upload',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),  // Page de login par défaut
    );
  }
}

// Page de Login
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final uri = Uri.parse("http://192.168.1.102:5001/login");  // Route Flask de login
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String token = data['access_token'];  // JWT reçu

      Fluttertoast.showToast(msg: "Login Successful!");

      // Naviguer vers la page d'upload après connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UploadImageScreen(token: token),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Login Failed! ${json.decode(response.body)['error']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
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
              onPressed: login,
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}

// Page d'Upload après connexion
class UploadImageScreen extends StatefulWidget {
  final String token;  // JWT Token passé de la page de login
  UploadImageScreen({required this.token});

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _image;
  Uint8List? _webImage;
  final picker = ImagePicker();
  Map<String, dynamic>? _extractedData;
  String _uploadStatus = '';

  Future getImage(bool fromCamera) async {
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        var f = await pickedFile.readAsBytes();
        setState(() {
          _webImage = f;
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      Fluttertoast.showToast(msg: 'No image selected.');
    }
  }

  Future uploadImage() async {
    if (_webImage == null && _image == null) return;

    var uri = Uri.parse("http://192.168.1.102:5000/upload_cin");
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer ${widget.token}';  // Ajouter le token JWT

    http.MultipartFile multipartFile;

    if (kIsWeb) {
      var mimeType = lookupMimeType('', headerBytes: _webImage!) ?? 'application/octet-stream';
      multipartFile = http.MultipartFile.fromBytes(
        'image',
        _webImage!,
        contentType: MediaType.parse(mimeType),
        filename: 'upload.png',
      );
    } else {
      var mimeType = lookupMimeType(_image!.path) ?? 'application/octet-stream';
      multipartFile = await http.MultipartFile.fromPath(
        'image',
        _image!.path,
        contentType: MediaType.parse(mimeType),
      );
    }

    request.files.add(multipartFile);

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        setState(() {
          _uploadStatus = 'Data extracted successfully!';
          _extractedData = json.decode(responseBody)['data'];
        });
        Fluttertoast.showToast(msg: 'Upload successful!');
      } else {
        setState(() {
          _uploadStatus = 'Failed to upload image: ${response.statusCode}';
        });
        Fluttertoast.showToast(msg: 'Upload failed!');
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error: $e';
      });
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _webImage == null && _image == null
                ? Text('No image selected.')
                : kIsWeb
                    ? Image.memory(_webImage!, height: 300)
                    : Image.file(_image!, height: 300),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () => getImage(false), child: Text('Gallery')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: () => getImage(true), child: Text('Camera')),
              ],
            ),
            ElevatedButton(onPressed: uploadImage, child: Text('Upload')),
            SizedBox(height: 20),
            Text(_uploadStatus, style: TextStyle(color: Colors.green, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
