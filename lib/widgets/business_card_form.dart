

import 'package:flutter/material.dart';

class BusinessCardForm extends StatefulWidget {
  BusinessCardForm({Key? key}) : super(key: key);

  @override
  BusinessCardFormState createState() => BusinessCardFormState();
}

class BusinessCardFormState extends State<BusinessCardForm> {
  final nameController = TextEditingController();
  final jobRoleController = TextEditingController();
  final numberController = TextEditingController();
  final websiteController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  void updateFields(Map<String, String> data) {
    setState(() {
      nameController.text = data['name'] ?? '';
      jobRoleController.text = data['jobRole'] ?? '';
      numberController.text = data['number'] ?? '';
      websiteController.text = data['website'] ?? '';
      emailController.text = data['email'] ?? '';
      addressController.text = data['address'] ?? '';
    });
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField('Name', nameController),
        _buildTextField('Job Role', jobRoleController),
        _buildTextField('Phone Number', numberController),
        _buildTextField('Website', websiteController),
        _buildTextField('Email', emailController),
        _buildTextField('Address', addressController, maxLines: 3),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    jobRoleController.dispose();
    numberController.dispose();
    websiteController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }
}