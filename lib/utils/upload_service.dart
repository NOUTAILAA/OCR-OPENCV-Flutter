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
      request.headers['Authorization'] = 'Bearer $token';  // Ajouter JWT pour sécurité

      http.MultipartFile multipartFile;

      // Upload pour Web
      if (kIsWeb && webImage != null) {
        var mimeType = lookupMimeType('', headerBytes: webImage) ?? 'application/octet-stream';
        multipartFile = http.MultipartFile.fromBytes(
          'image',
          webImage,
          contentType: MediaType.parse(mimeType),
          filename: 'upload.png',
        );
      } 
      // Upload pour Mobile / Desktop
      else if (image != null) {
        var mimeType = lookupMimeType(image.path) ?? 'application/octet-stream';
        multipartFile = await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType.parse(mimeType),
        );
      } else {
        return 'No image selected!';
      }

      // Ajouter le fichier à la requête
      request.files.add(multipartFile);

      // Envoi de la requête
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extraction de la partie JSON brute
        final dataString = responseBody;
        final startIndex = dataString.indexOf('{');
        final endIndex = dataString.lastIndexOf('}');

        if (startIndex != -1 && endIndex != -1) {
          try {
            final jsonString = dataString.substring(startIndex, endIndex + 1);
            final data = jsonDecode(jsonString);
            return " ${data}";
          } catch (e) {
            return "Error decoding data: $e";
          }
        } else {
          return "Invalid response format!";
        }
      } else {
        return "Upload failed! Status: ${response.statusCode}";
      }
    } catch (e) {
      return "Error during upload: $e";
    }
  }
}