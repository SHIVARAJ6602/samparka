import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

Future<void> sendExcelFile(String opt) async {
  // Step 1: Pick the Excel file
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx', 'xls'],
  );

  if (result != null && result.files.isNotEmpty) {
    String filePath = result.files.single.path!;

    // Step 2: Prepare the file to send with Dio
    File file = File(filePath);
    FormData formData = FormData.fromMap({
      'action': opt,
      'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });

    // Step 3: Send the file to Django server
    Dio dio = Dio();
    try {
      final response = await dio.post(
        'http://your-django-server-url/api/upload/',  // Replace with your actual Django endpoint
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("File uploaded successfully!");
        print(response.data);  // Optionally handle the response
      } else {
        print("Failed to upload file.");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  } else {
    print('No file selected');
  }
}
