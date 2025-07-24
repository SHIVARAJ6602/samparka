import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../Service/api_service.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  List<File> _images = [];
  bool _isSubmitting = false;

  /// Picks multiple images using ImagePicker
  Future<void> _pickImages() async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles != null) {
        setState(() {
          _images = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick images: $e');
    }
  }

  /// Submits feedback to the API
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final description = _descriptionController.text.trim();
    final data = [email, description, _images];

    setState(() => _isSubmitting = true);

    try {
      final success = await _apiService.sendFeedBack(data);
      final message = success ? "Feedback submitted successfully!" : "Submission failed!";
      _showSnackBar(message, success: success);

      if (success) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar("Error: $e", success: false);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// Helper method to show a snack bar
  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  /// Builds a label
  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 17,
      color: Color.fromRGBO(2, 40, 60, 1),
    ),
  );

  /// Builds the gradient submit button
  Widget _buildGradientButton(String text, VoidCallback onPressed) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color.fromRGBO(2, 40, 60, 1), Color.fromRGBO(60, 170, 145, 1)],
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
  );

  /// Shows selected image thumbnails with a remove option
  Widget _buildImagePreview() {
    if (_images.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('No images selected', style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: _images.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _images.removeAt(index)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*AutoSizeText(
                'Submit a Feedback or Report a bug',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(5, 50, 70, 1.0),
                ),
                minFontSize: 26.floorToDouble(),
                stepGranularity: 1.0,
                overflow: TextOverflow.ellipsis,
              ),*/
              Text(
                'Submit a Feedback \nor Report a bug/Error',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.045 + 15,
                  fontWeight: FontWeight.w900,
                  color: Color.fromRGBO(2, 40, 60, 1),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('Email (for communication purpose)'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
                decoration: InputDecoration(
                  hintText: 'For communication purpose',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 15),

              _buildLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                validator: (value) => value == null || value.isEmpty ? 'Description is required.' : null,
                decoration: InputDecoration(
                  hintText: 'Describe your feedback or experience.\nIf you\'re reporting a bug, please provide as much detail as possible to help us understand and resolve the issue.',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 15),

              _buildLabel('Screenshots / Images'),
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text('Pick Images'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromRGBO(2, 40, 60, 1),
                ),
              ),

              _buildImagePreview(),
              const SizedBox(height: 20),

              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : _buildGradientButton('Submit Feedback', _submitFeedback),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
