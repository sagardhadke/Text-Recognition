import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(home: MyMlKitScanNow()));
}

class MyMlKitScanNow extends StatefulWidget {
  @override
  _MyMlKitScanNowState createState() => _MyMlKitScanNowState();
}

class _MyMlKitScanNowState extends State<MyMlKitScanNow> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobRoleController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        processImage(_image!);
      }
    });
  }

  Future<void> processImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textDetector.processImage(inputImage);

    String text = recognizedText.text;
    Map<String, String> extractedInfo = extractInformation(text);

    setState(() {
      nameController.text = extractedInfo['name'] ?? '';
      jobRoleController.text = extractedInfo['jobRole'] ?? '';
      numberController.text = extractedInfo['number'] ?? '';
      websiteController.text = extractedInfo['website'] ?? '';
      emailController.text = extractedInfo['email'] ?? '';
      addressController.text = extractedInfo['address'] ?? '';
    });

    textDetector.close();
  }

  Map<String, String> extractInformation(String text) {
    Map<String, String> info = {};
    List<String> lines = text.split('\n');

    // Basic extraction logic - you may need to enhance this based on your needs
    RegExp emailRegex = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w+\b');
    RegExp phoneRegex = RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b');
    RegExp websiteRegex = RegExp(r'\bwww\.[a-zA-Z0-9-]+\.[a-zA-Z]+\b');

    String? name;
    String? jobRole;
    String? number;
    String? website;
    String? email;
    List<String> addressParts = [];

    for (String line in lines) {
      if (email == null && emailRegex.hasMatch(line)) {
        email = emailRegex.firstMatch(line)?.group(0);
      }
      if (number == null && phoneRegex.hasMatch(line)) {
        number = phoneRegex.firstMatch(line)?.group(0);
      }
      if (website == null && websiteRegex.hasMatch(line)) {
        website = websiteRegex.firstMatch(line)?.group(0);
      }

      // Assume first line is name if not found yet
      if (name == null &&
          !line.contains('@') &&
          !line.contains('www.') &&
          !phoneRegex.hasMatch(line) &&
          line.trim().isNotEmpty) {
        name = line.trim();
      }
      // Assume second line is job role if not found yet
      else if (jobRole == null &&
          !line.contains('@') &&
          !line.contains('www.') &&
          !phoneRegex.hasMatch(line) &&
          line.trim().isNotEmpty) {
        jobRole = line.trim();
      }
      // Collect remaining lines as potential address
      else if (!line.contains('@') &&
          !line.contains('www.') &&
          !phoneRegex.hasMatch(line) &&
          line.trim().isNotEmpty) {
        addressParts.add(line.trim());
      }
    }

    info['name'] = name ?? '';
    info['jobRole'] = jobRole ?? '';
    info['number'] = number ?? '';
    info['website'] = website ?? '';
    info['email'] = email ?? '';
    info['address'] = addressParts.join(', ');

    return info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Card Scanner'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
              ),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Pick Business Card Image'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: jobRoleController,
              decoration: InputDecoration(
                labelText: 'Job Role',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: numberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: websiteController,
              decoration: InputDecoration(
                labelText: 'Website',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
