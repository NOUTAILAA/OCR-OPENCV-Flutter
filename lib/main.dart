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
      title: 'Upload Image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UploadImageScreen(),
    );
  }
}

class UploadImageScreen extends StatefulWidget {
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
          _image = File(pickedFile.path);
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
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _webImage == null && _image == null
                ? Text('No image selected.')
                : kIsWeb
                    ? Image.memory(
                        _webImage!,
                        height: 300,
                      )
                    : Image.file(
                        _image!,
                        height: 300,
                      ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => getImage(false),
                  child: Text('Pick from Gallery'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => getImage(true),
                  child: Text('Capture with Camera'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            Text(
              _uploadStatus,
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
            if (_extractedData != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _extractedData!.entries.map((entry) {
                    return Text("${entry.key}: ${entry.value}",
                        style: TextStyle(fontSize: 18));
                  }).toList(),
                ),
              )
          ],
        ),
      ),
    );
  }
}