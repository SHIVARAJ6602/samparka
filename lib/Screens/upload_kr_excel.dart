import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Service/api_service.dart';

class UploadKRExcel extends StatefulWidget {
  const UploadKRExcel({super.key});

  @override
  _UploadExcelKRPageState createState() => _UploadExcelKRPageState();
}

class _UploadExcelKRPageState extends State<UploadKRExcel> {
  String? _statusMessage = "No file selected.";
  final ApiService apiService = ApiService();
  File? _failedExcel;

  // Method to show a confirmation dialog
  Future<void> _showConfirmationDialog() async {
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm File Upload"),
          content: Text("Are you sure you want to pick a file for upload?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);  // User cancels
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);  // User confirms
              },
              child: Text("Proceed"),
            ),
          ],
        );
      },
    );

    if (shouldProceed == true) {
      _uploadFile();  // Proceed with file picking
    }
  }

  Future<void> _uploadFile() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (pickedFile == null) {
      setState(() => _statusMessage = "No file selected.");
      return;
    }

    File file = File(pickedFile.files.single.path!);
    setState(() {
      _statusMessage = "Uploading...";
    });

    final failedFile = await apiService.addKR(file);

    if (failedFile != null) {
      setState(() {
        _failedExcel = failedFile;
        _statusMessage = "Some entries failed. File saved at:\n${failedFile.path}";
      });

      _showFailureDialog(failedFile.path);
    } else {
      setState(() {
        _statusMessage = "File uploaded successfully!";
      });
    }
  }

  void _showFailureDialog(String filePath) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Some entries failed"),
        content: Text("Failed records have been saved at:\n$filePath"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final file = File(filePath);
              if (await file.exists()) {
                await OpenFile.open(file.path);
              }
            },
            child: Text("Open File"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Karyakartha Excel")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _showConfirmationDialog,  // Show the confirmation dialog first
                child: Text("Pick and Upload Excel File"),
              ),
              SizedBox(height: 20),
              Text(
                _statusMessage ?? "",
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
