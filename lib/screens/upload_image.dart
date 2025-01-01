import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/foundation.dart';
import '../utils/upload_service.dart';
import 'login_screen.dart';

class UploadImageScreen extends StatefulWidget {
  final String token;

  UploadImageScreen({required this.token});

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _image;
  Uint8List? _webImage;
  final picker = ImagePicker();
  String _uploadStatus = '';
  bool _isUploading = false;
  Map<String, dynamic>? _extractedData;

  // Méthode pour sélectionner une image
  Future<void> getImage(bool fromCamera) async {
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes();
      } else {
        _image = File(pickedFile.path);
      }
      setState(() {});  // Mise à jour immédiate après sélection d'image
    } else {
      Fluttertoast.showToast(msg: 'No image selected.');
    }
  }

  // Méthode d'upload d'image
  Future<void> uploadImage() async {
    if (_image == null && _webImage == null) {
      Fluttertoast.showToast(msg: 'Please select an image first.');
      return;
    }

    setState(() {
      _isUploading = true;  // Démarrer le chargement
    });

    final result = await ApiService.uploadImage(
      _image,
      _webImage,
      widget.token,
    );

    setState(() {
      _uploadStatus = result ?? 'Upload failed!';
      _isUploading = false;  // Arrêter le chargement après l'upload
    });

    // Décoder les données après upload réussi
    if (result != null && result.contains('Data:')) {
      final startIndex = result.indexOf('{');
      final endIndex = result.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        try {
          final extracted = jsonDecode(result.substring(startIndex, endIndex + 1));
          setState(() {
            _extractedData = extracted;
          });
        } catch (e) {
          Fluttertoast.showToast(msg: 'Error decoding data: $e');
        }
      }
    }
  }

  // Méthode pour se déconnecter
  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Affichage de l'image sélectionnée
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    child: _webImage == null && _image == null
                        ? Center(
                            child: Text(
                              'No image selected.',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : kIsWeb
                            ? Image.memory(_webImage!, fit: BoxFit.cover)
                            : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 30),

                // Boutons pour sélectionner une image
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => getImage(false),
                      icon: Icon(Icons.photo),
                      label: Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () => getImage(true),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Bouton d'upload
                _isUploading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: uploadImage,
                        child: Text('Upload Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                SizedBox(height: 20),

                Text(
                  _uploadStatus,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 20),

                // Affichage des données extraites après l'upload
            if (_extractedData != null)
  Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _extractedData!.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${entry.key}: ",  // Clé (ex: nom)
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                ),
                TextSpan(
                  text: entry.value.toString(),  // Valeur (ex: TEARGAMMANE)
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
