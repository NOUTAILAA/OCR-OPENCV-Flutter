import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart';


class ApiService {
  static const String baseUrl = "http://192.168.11.113:5000";

// Méthode d'upload d'image
 // Méthode d'upload d'image
  static Future<String?> uploadImage(File? image, Uint8List? webImage, String token) async {
    try {
      var uri = Uri.parse("$baseUrl/upload_cin");
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      http.MultipartFile multipartFile;

      if (kIsWeb && webImage != null) {
        var mimeType = lookupMimeType('', headerBytes: webImage) ?? 'application/octet-stream';
        multipartFile = http.MultipartFile.fromBytes(
          'image',
          webImage,
          contentType: MediaType.parse(mimeType),
          filename: 'upload.png',
        );
      } else if (image != null) {
        var mimeType = lookupMimeType(image.path) ?? 'application/octet-stream';
        multipartFile = await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType.parse(mimeType),
        );
      } else {
        return 'No image selected!';
      }

      request.files.add(multipartFile);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      // Ajouter ce print pour voir la réponse brute
      print("Réponse brute du serveur : $responseBody");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseBody;
      } else {
        return "Upload failed! Status: ${response.statusCode}";
      }
    } catch (e) {
      print("Erreur lors de l'upload : $e");
      return "Error during upload: $e";
    }
  }

}