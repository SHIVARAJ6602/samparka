import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<void> _showConfirmationDialog() async {
    final bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm File Upload"),
          content: const Text("Are you sure you want to pick a file for upload?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Proceed"),
            ),
          ],
        );
      },
    );

    if (shouldProceed == true) {
      _uploadFile();
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

  Future<String> _getExternalDirectory() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download/samparka';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<void> downloadTemplateFile() async {
    try {
      final exPath = await _getExternalDirectory();
      await Directory(exPath).create(recursive: true);

      final byteData = await rootBundle.load('assets/files/Karyakartha Data Template (Vibhaga).xlsx');

      String baseName = 'Karyakartha Data Template (Vibhaga)';
      String extension = '.xlsx';
      String fullPath = '$exPath/$baseName$extension';

      int count = 1;
      while (await File(fullPath).exists()) {
        fullPath = '$exPath/${baseName}_$count$extension';
        count++;
      }

      final file = File(fullPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      _showDownloadedDialog(fullPath);
    } catch (e) {
      print("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to download the template.")),
      );
    }
  }

  void _showDownloadedDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Template Downloaded"),
          content: Text("The template has been saved to:\n$filePath"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final file = File(filePath);
                if (await file.exists()) {
                  try {
                    await OpenFile.open(file.path);
                  } catch (e) {
                    print('Error opening file: $e');
                  }
                }
              },
              child: const Text("Open"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _acknowledgementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Download Template"),
          content: const Text("Do you want to download the template?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await downloadTemplateFile();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showFailureDialog(String filePath) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Some entries failed"),
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
            child: const Text("Open File"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
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
        title: const Text("Upload Karyakartha Excel"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  child: const Text("Pick and Upload Excel File"),
                ),
                const SizedBox(height: 20),
                Text(
                  _statusMessage ?? "",
                  style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Note:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Valid options for the fields are as follows:",
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "• Shreni: Intellectuals, Religious, Economic, Administration,\n"
                      "  Law and Judiciary, Sports, Social Leaders and Organizations,\n"
                      "  Healthcare, Art and Award Winners, Science and Research",
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.1,
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(60, 245, 200, 1.0),
                        Color.fromRGBO(2, 40, 60, 1),
                      ],
                    ),
                  ),
                  child: Center(
                    child: TextButton(
                      onPressed: () => _acknowledgementDialog(context),
                      child: const Text(
                        "Download Template",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
