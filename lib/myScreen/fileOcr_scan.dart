import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class MyFileOcr extends StatefulWidget {
  @override
  _MyFileOcrState createState() => _MyFileOcrState();
}

class _MyFileOcrState extends State<MyFileOcr> {
  File? _image;
  String _extractedText = '';
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });

      // Resize image to a smaller size (optional, but helps with OCR speed)
      final image = img.decodeImage(_image!.readAsBytesSync())!;
      final resizedImage = img.copyResize(image, width: 800);

      // Save the resized image to a new file
      final resizedFile = File('${_image!.path}_resized.jpg')
        ..writeAsBytesSync(img.encodeJpg(resizedImage));

      // Perform OCR
      final extractedText = await FlutterTesseractOcr.extractText(
        resizedFile.path,
        language: 'eng',
        args: {
          "psm": "4",
          "tessdata": "assets/tessdata", // Path to the tessdata directory
          "configfile": "assets/tessdata_config.json" // Path to the tessdata config file
        },
      );
      setState(() {
        _extractedText = extractedText;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR Scanner'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.camera_alt),
              label: Text('Scan Image'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              Text(
                _extractedText.isNotEmpty ? _extractedText : 'No text extracted.',
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyFileOcr(),
  ));
}