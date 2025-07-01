import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Service/api_service.dart';

class UploadGVExcel extends StatefulWidget {
  const UploadGVExcel({super.key});

  @override
  _UploadExcelGVPageState createState() => _UploadExcelGVPageState();
}

class _UploadExcelGVPageState extends State<UploadGVExcel> {
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

    final failedFile = await apiService.addGV(file);

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
      return '/storage/emulated/0/Download/samparka'; // Android-specific path
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<void> downloadTemplateFile() async {
    try {
      final exPath = await _getExternalDirectory();
      await Directory(exPath).create(recursive: true);

      final byteData = await rootBundle.load('assets/files/Ganyavyakthi Data Template (Vibhaga).xlsx');

      String baseName = 'Ganyavyakthi Data Template (Vibhaga)';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        title: const Text("Upload GanyaVyakti Excel"),
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
                  "Important Notice for Data Collection:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Please ensure that all collected data strictly adheres to the predefined values specified for the following fields:\n\n"
                      "1. Phone Number:\n"
                      "   10 digit without country code.\n\n"
                      "2. Soochi:\n"
                      "   Valid options are:\n"
                      "   - AB\n"
                      "   - PS\n"
                      "   - JS\n"
                      "   (AkhilaBharthiya, PranthyaSampark, JillaSampark)\n\n"
                      "3. Shreni:\n"
                      "   Valid options are:\n"
                      "   - Intellectuals\n"
                      "   - Religious\n"
                      "   - Economic\n"
                      "   - Administration\n"
                      "   - Law and Judiciary\n"
                      "   - Sports\n"
                      "   - Social Leaders and Organizations\n"
                      "   - Healthcare\n"
                      "   - Art and Award Winners\n"
                      "   - Science and Research\n\n"
                      "4. Level of samparka:\n"
                      "   Valid options are:\n"
                      "   - Sampark\n"
                      "   - Sahavas\n"
                      "   - Samarthan\n"
                      "   - Sahabhag\n\n"
                      "Any deviation from the specified values will result in data inconsistency and may cause issues during processing or validation, which leads to rejection during registration.\n\n"
                      "*Do not edit any column name*",
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 20),
                // Container with the Download Template button
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.1,
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(198, 198, 198, 1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromRGBO(198, 198, 198, 1.0),
                      width: 1,
                    ),
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
