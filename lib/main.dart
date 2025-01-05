// // main.dart
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';

// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: HomeScreen(),
//     theme: ThemeData(
//       primarySwatch: Colors.blue,
//       useMaterial3: true,
//     ),
//   ));
// }

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Business Card Scanner'),
//         centerTitle: true,
//       ),
//       body: Container(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // _buildScannerButton(
//             //   context,
//             //   'ML Kit Scanner',
//             //   MLKitScannerScreen(),
//             //   Colors.blue,
//             //   Icons.document_scanner,
//             // ),
//             // SizedBox(height: 20),
//             _buildScannerButton(
//               context,
//               'ML Text Scanner',
//               MLTextScannerScreen(),
//               Colors.green,
//               Icons.text_fields,
//             ),
//             // SizedBox(height: 20),
//             // _buildScannerButton(
//             //   context,
//             //   'Tesseract Scanner',
//             //   // TesseractScannerScreen(),
//             //   Colors.purple,
//             //   Icons.scanner,
//             // ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildScannerButton(BuildContext context, String title, Widget screen,
//       Color color, IconData icon) {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       child: ElevatedButton.icon(
//         icon: Icon(icon, color: Colors.white),
//         label: Text(title, style: TextStyle(fontSize: 18, color: Colors.white)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//         ),
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => screen),
//         ),
//       ),
//     );
//   }
// }


// // Second Screen: ML Text Scanner
// class MLTextScannerScreen extends StatefulWidget {
//   @override
//   _MLTextScannerScreenState createState() => _MLTextScannerScreenState();
// }

// class _MLTextScannerScreenState extends State<MLTextScannerScreen> {
//   File? _image;
//   bool _isLoading = false;
//   final _nameController = TextEditingController();
//   final _jobController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _websiteController = TextEditingController();
//   final _addressController = TextEditingController();

//   Future<void> _scanImage() async {
//     setState(() => _isLoading = true);
//     try {
//       final image = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (image == null) return;

//       setState(() => _image = File(image.path));

//       final textRecognizer =
//           TextRecognizer(script: TextRecognitionScript.latin);
//       final inputImage = InputImage.fromFile(_image!);
//       final RecognizedText recognizedText =
//           await textRecognizer.processImage(inputImage);

//       _processRecognizedText(recognizedText.text);
//       textRecognizer.close();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _processRecognizedText(String text) {
//     final lines = text.split('\n');
//     final emailPattern = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w+\b');
//     // final phonePattern = RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b');
//     final phonePattern = RegExp(r'(\+?\d{1,2}\s?)?(\(?\d{3}\)?[-.\s]?)?\d{3}[-.\s]?\d{4}');

//     final websitePattern = RegExp(r'\bwww\.[a-zA-Z0-9-]+\.[a-zA-Z]+\b');

//     setState(() {
//       _nameController.text = lines.isNotEmpty ? lines[0] : '';
//       _jobController.text = lines.length > 1 ? lines[1] : '';
//       _phoneController.text = phonePattern.hasMatch(text)
//           ? phonePattern.firstMatch(text)!.group(0)!
//           : '';
//       _emailController.text = emailPattern.hasMatch(text)
//           ? emailPattern.firstMatch(text)!.group(0)!
//           : '';
//       _websiteController.text = websitePattern.hasMatch(text)
//           ? websitePattern.firstMatch(text)!.group(0)!
//           : '';
//       _addressController.text = lines.length > 2 ? lines.last : '';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ML Text Scanner'),
//         backgroundColor: Colors.green,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             if (_image != null)
//               Card(
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Container(
//                   width: double.infinity,
//                   height: 200,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(15),
//                     child: Image.file(_image!, fit: BoxFit.cover),
//                   ),
//                 ),
//               ),
//             SizedBox(height: 20),
//             Container(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: EdgeInsets.symmetric(vertical: 15),
//                   shape: StadiumBorder(),
//                 ),
//                 onPressed: _scanImage,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.document_scanner, color: Colors.white),
//                     SizedBox(width: 10),
//                     Text('Scan Card', style: TextStyle(color: Colors.white)),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             if (_isLoading)
//               CircularProgressIndicator(color: Colors.green)
//             else
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(15),
//                   child: Column(
//                     children: [
//                       _buildTextField(_nameController, 'Name', Icons.person),
//                       _buildTextField(_jobController, 'Job Title', Icons.work),
//                       _buildTextField(_phoneController, 'Phone', Icons.phone),
//                       _buildTextField(_emailController, 'Email', Icons.email),
//                       _buildTextField(_websiteController, 'Website', Icons.web),
//                       _buildTextField(
//                           _addressController, 'Address', Icons.location_on,
//                           maxLines: 3),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String label, IconData icon,
//       {int maxLines = 1}) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 15),
//       child: TextFormField(
//         controller: controller,
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, color: Colors.green),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: Colors.green, width: 2),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:text_ocr_my/screens/home.dart';
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.purple,
      useMaterial3: true,
    ),
    home: MyHome()
  ));
}
