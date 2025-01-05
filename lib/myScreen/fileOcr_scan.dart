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
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
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
      final extractedText =
          await FlutterTesseractOcr.extractText(resizedFile.path);
      _processExtractedText(extractedText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processExtractedText(String text) {
    final lines = text.split('\n');

    // Regular expressions for matching
    final emailPattern = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w+\b');
    final phonePattern = RegExp(
        r'\b(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})\b');
    final websitePattern = RegExp(
        r'\b(?:https?:\/\/)?(?:www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]+(?:\/[^\s]*)?');

    String name = '';
    String jobTitle = '';
    String phone = '';
    String email = '';
    String website = '';
    List<String> addressParts = [];

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Extract email
      if (email.isEmpty && emailPattern.hasMatch(line)) {
        email = emailPattern.firstMatch(line)!.group(0)!;
        continue;
      }

      // Extract phone
      if (phone.isEmpty && phonePattern.hasMatch(line)) {
        phone = phonePattern.firstMatch(line)!.group(0)!;
        continue;
      }

      // Extract website
      if (website.isEmpty && websitePattern.hasMatch(line)) {
        website = websitePattern.firstMatch(line)!.group(0)!;
        continue;
      }

      // Assume first non-matched line is name
      if (name.isEmpty) {
        name = line;
        continue;
      }

      // Assume second non-matched line is job title
      if (jobTitle.isEmpty) {
        jobTitle = line;
        continue;
      }

      // Collect remaining lines as address
      addressParts.add(line);
    }

    setState(() {
      _nameController.text = name;
      _jobController.text = jobTitle;
      _phoneController.text = phone;
      _emailController.text = email;
      _websiteController.text = website;
      _addressController.text = addressParts.join(', ');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Card Scanner'),
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
              label: Text('Scan Business Card'),
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
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person,
                      ),
                      _buildTextField(
                        controller: _jobController,
                        label: 'Job Title',
                        icon: Icons.work,
                      ),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                      ),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                      ),
                      _buildTextField(
                        controller: _websiteController,
                        label: 'Website',
                        icon: Icons.language,
                      ),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.location_on,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
