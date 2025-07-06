import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  List<File> _images = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _submitFeedback() async {
    final description = _descriptionController.text;
    final email = _emailController.text;

    if (description.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email and description are required')),
      );
      return;
    }

    var uri = Uri.parse('http://yourserver.com/api/feedback/');
    var request = http.MultipartRequest('POST', uri)
      ..fields['description'] = description
      ..fields['email'] = email;

    for (var image in _images) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }

    var response = await request.send();
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully')),
      );
      _descriptionController.clear();
      _emailController.clear();
      setState(() => _images.clear());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback')),
      );
    }
  }

  Widget buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: const Color.fromRGBO(2, 40, 60, 1),
      ),
    );
  }

  Widget buildGradientButton(String text, VoidCallback onPressed) {
    return Container(
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
  }

  Widget buildImagePreview() {
    if (_images.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'No images selected',
          style: TextStyle(color: Colors.grey),
        ),
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
                  onTap: () {
                    setState(() {
                      _images.removeAt(index);
                    });
                  },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submit a Bug or Feedback',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.045 + 15,
                fontWeight: FontWeight.w900,
                color: Color.fromRGBO(2, 40, 60, 1),
              ),
            ),
            SizedBox(height: 20),

            buildLabel('Email'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            SizedBox(height: 15),

            buildLabel('Description'),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            SizedBox(height: 15),

            buildLabel('Screenshots / Images'),
            ElevatedButton(
              onPressed: _pickImages,
              child: Text('Pick Images'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromRGBO(2, 40, 60, 1),
              ),
            ),

            buildImagePreview(),

            SizedBox(height: 20),
            buildGradientButton('Submit Feedback', _submitFeedback),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
