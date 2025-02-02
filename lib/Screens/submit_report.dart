import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SubmitReportPage extends StatefulWidget {
  const SubmitReportPage({super.key});

  @override
  _SubmitReportPageState createState() => _SubmitReportPageState();
}

class _SubmitReportPageState extends State<SubmitReportPage> {

  final TextEditingController reportDataController = TextEditingController();

  List<File> _imageFiles = [];

  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Title
                                Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: largeFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "Report",
                                  style: TextStyle(
                                    fontSize: largeFontSize+20,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                ),
                                SizedBox(height: 10),
                                //Meeting details
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
                                  padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                                  child: Container(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // First Column: meeting details
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.40,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Meeting Name',  // Dynamic name
                                                style: TextStyle(
                                                  fontSize: largeFontSize + 6,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Date: xx/xx/xxxx',  // Dynamic designation
                                                style: TextStyle(
                                                  fontSize: smallFontSize,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 1),
                                              Text(
                                                'Time: xx:xx:xx',  // Dynamic description
                                                style: TextStyle(
                                                  fontSize: smallFontSize - 2,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 1),
                                              Text(
                                                'Location: Location,Location',  // Dynamic hashtags
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
                                ),
                                //details
                                SizedBox(height: 10),
                                Container(
                                  //height: MediaQuery.of(context).size.height,
                                  child: TextField(
                                    controller: reportDataController,
                                    maxLines: null,
                                    minLines: 5,
                                    decoration: InputDecoration(
                                      hintText: 'Enter the meeting report',
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade400, // Set the grey border color
                                          width: 1.0,  // Set the border width
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade600, // Darker grey when focused
                                          width: 1.5, // Slightly thicker border when focused
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade400, // Light grey when not focused
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),


                                //add images
                                SizedBox(height: 10),
                                Container(
                                  child: Center(
                                    child: Wrap(
                                      spacing: 8.0, // Horizontal space between items
                                      runSpacing: 8.0, // Vertical space between items
                                      children: [
                                        // Generate the image boxes
                                        ...List.generate(_imageFiles.length, (index) {
                                          return Stack(
                                            children: [
                                              // Image box
                                              Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: Colors.grey.shade400,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.file(
                                                    _imageFiles[index],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              // Delete button
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    _deleteImage(index); // Delete the image when pressed
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                        // Add the "Add Image" button at the end
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: TextButton(
                                            onPressed: _pickImages, // Call the image picker function
                                            child: Text(
                                              '+', // The button text
                                              style: TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade300, // Set the color of the text
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),


                                //Submit button
                                SizedBox(height: 30),
                                Expanded(child: SizedBox()),
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
                                          Color.fromRGBO(60, 170, 145, 1.0)
                                        ],
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 10), // Adjust padding
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,  // Center the row content
                                          children: [
                                            const Text(
                                              'Submit Report',
                                              style: TextStyle(
                                                fontSize: 23,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),  // Add space between the text and the image
                                            Transform.rotate(
                                              angle: 4.7124,  // Rotate the arrow 90 degrees
                                              child: Image.asset(
                                                'assets/icon/arrow.png',
                                                color: Colors.white,
                                                width: 15,  // Adjust the size of the image
                                                height: 15, // Adjust the size of the image
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),


                                /*Container(
                                child: Column(
                                  children: List.generate(_imageFiles.length, (index) {
                                    return Stack(
                                      children: [
                                        // Image box
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.file(
                                              _imageFiles[index],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        // Delete button
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              _deleteImage(index); // Delete the image when pressed
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              )*/

                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
