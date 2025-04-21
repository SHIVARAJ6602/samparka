import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../Service/api_service.dart';

class UploadKRExcel extends StatefulWidget {
  const UploadKRExcel({super.key});

  @override
  _UploadExcelKRPageState createState() => _UploadExcelKRPageState();
}

class _UploadExcelKRPageState extends State<UploadKRExcel> {
  String? _statusMessage = "No file selected.";
  final ApiService apiService = ApiService(); // Your ApiService instance

  void _uploadFile() async {
    // Step 1: Pick the Excel file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);

      setState(() {
        _statusMessage = "Uploading file...";
      });

      // Step 2: Call the API service with the selected file
      bool success = await apiService.addUsers(file);

      setState(() {
        if (success) {
          _statusMessage = "File upload complete!";
        } else {
          _statusMessage = "Failed to upload file.";
        }
      });
    } else {
      setState(() {
        _statusMessage = "No file selected.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel File Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _uploadFile,
              child: const Text("Pick and Upload Excel File"),
            ),
            const SizedBox(height: 20),
            Text(
              _statusMessage ?? "",
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
