import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../Service/api_service.dart';

class SubmitReportPage extends StatefulWidget {

  final String type;
  final String id;
  final Map<String, dynamic> data;

  const SubmitReportPage(this.id,this.type,this.data,{super.key,});

  @override
  _SubmitReportPageState createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {

  final apiService = ApiService();

  late Map<String, dynamic> data;

  final TextEditingController reportDataController = TextEditingController();

  List<File> _imageFiles = [];

  final ImagePicker _picker = ImagePicker();

  String formatDate(String isoDateTime) {
    try {
      // Parse the ISO 8601 string to DateTime object
      DateTime dateTimeObj = DateTime.parse(isoDateTime);

      return DateFormat('dd MMM yyyy').format(dateTimeObj);
    } catch (e) {
      // If the date parsing fails, return a default message
      return 'Invalid Date';
    }
  }
  String formatTime(String isoDateTime) {
    try {
      // Parse the ISO 8601 string to DateTime object
      DateTime dateTimeObj = DateTime.parse(isoDateTime);

      return DateFormat('HH:MM a').format(dateTimeObj);
    } catch (e) {
      // If the date parsing fails, return a default message
      return 'Invalid Date';
    }
  }

  // Function to pick images
  Future<void> _pickImages() async {
    // Pick multiple images
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  // Function to delete an image
  void _deleteImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> submitReport() async {
    print('${widget.id} $_imageFiles ${reportDataController.text}');
    bool status = await apiService.submitReport(widget.id, widget.type, _imageFiles, reportDataController.text);
    if(status){
      print('successful');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event Scheduled'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context,true);
    }else{
      print('failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed TO Schedule Event'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    data = widget.data;
    print('data received sub report $data');
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          "Submit Report",
                          style: TextStyle(
                            fontSize: largeFontSize + 20,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromRGBO(5, 50, 70, 1.0),
                          ),
                        ),
                        SizedBox(height: 10),

                        // Meeting Details Section
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(60, 170, 145, 1.0),
                                Color.fromRGBO(2, 40, 60, 1),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Meeting details
                              Container(
                                width: MediaQuery.of(context).size.width * 0.40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'],  // Dynamic name
                                      style: TextStyle(
                                        fontSize: largeFontSize + 6,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Date: ${formatDate(data['meeting_datetime'])}',  // Dynamic date
                                      style: TextStyle(
                                        fontSize: smallFontSize,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Time: ${formatTime(data['meeting_datetime'])}',  // Dynamic time
                                      style: TextStyle(
                                        fontSize: smallFontSize - 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Location: ${data['venue']}',  // Dynamic location
                                      style: TextStyle(
                                        fontSize: smallFontSize - 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),

                        // Report Input
                        TextField(
                          controller: reportDataController,
                          maxLines: null,
                          minLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Enter the meeting report',
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),

                        // Image Picker Section
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            // Generate image boxes dynamically
                            ...List.generate(_imageFiles.length, (index) {
                              return Stack(
                                children: [
                                  // Image Box
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _imageFiles[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Delete Button
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteImage(index),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            // Add Image Button
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: TextButton(
                                onPressed: _pickImages,
                                child: Text(
                                  '+',
                                  style: TextStyle(fontSize: 40, color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),

                        // Submit Button
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color.fromRGBO(2, 40, 60, 1),
                                  Color.fromRGBO(60, 170, 145, 1.0),
                                ],
                              ),
                            ),
                            child: TextButton(
                              onPressed: () {
                                submitReport();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Submit Report',
                                      style: TextStyle(
                                        fontSize: 23,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Transform.rotate(
                                      angle: 4.7124,
                                      child: Image.asset(
                                        'assets/icon/arrow.png',
                                        color: Colors.white,
                                        width: 15,
                                        height: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
