import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:samparka/Screens/meeting.dart';
import 'package:samparka/Screens/ProfilePage.dart';
import 'package:samparka/Screens/team.dart';
import 'package:samparka/Screens/view_report_meetings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import '../Service/api_service.dart';
import 'add_influencer.dart';
import 'help.dart';
import 'home.dart';
import 'package:flutter/services.dart';
import 'notifications.dart';

//openfile
  const types = {
    "application/pdf": "pdf",
    ".dwg": "application/x-autocad"
  };

class GenReportPage extends StatefulWidget {
  const GenReportPage({super.key});

  @override
  GenReportPageState createState() => GenReportPageState();
}

class GenReportPageState extends State<GenReportPage> {

  final apiService = ApiService();

  List<dynamic> data = [];
  late List<dynamic> result;

  int _selectedIndex = 3;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  late var selectedMeetingType = "Meeting";
  int influencerCount = 0;
  int influencerMet = 0;
  int activeTeamMembers = 0;
  int inactiveTeamMembers = 0;
  int individualMeetings = 0;
  int SGM = 0;
  int programs = 0;
  int baitek = 0;
  int successfullMeetings = 0; //bt 25 meetin 550

  bool isGenerating = false;
  bool viewDocument = false;

  var _openResult = 'Unknown';

  Future<void> _requestPermission() async {
    // Check the current status of storage permission
    var status = await Permission.storage.status;

    // If storage permission is not granted, request for it
    if (!status.isGranted) {
      // On Android 11+, check if the app has `MANAGE_EXTERNAL_STORAGE` permission
      if (await Permission.manageExternalStorage.isGranted) {
        // Already have storage permission on Android 11+
        return;
      } else {
        // Request storage permission for Android 10 and below
        if (await Permission.storage.request().isGranted) {
          // Permission granted, continue
          return;
        } else {
          // If permission denied, prompt user to open settings
          //openAppSettings();
          _showExplanationDialog(context);
        }
      }
    }
    // Else, handle cases where storage permission is granted
  }

  // Helper function to get external directory based on platform
  Future<String> _getExternalDirectory() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download/samparka'; // Android-specific path
    } else {
      // For iOS or other platforms, use application documents directory
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  void openDownloadedPDF(String filePath) {
    OpenFile.open(filePath);
  }

  Future<bool> genReport() async {
    try {
      isGenerating = true;
      // Get external directory path based on platform
      var exPath = await _getExternalDirectory();
      print("Saved Path: $exPath");

      // Create the directory if it does not exist
      await Directory(exPath).create(recursive: true);

      // Default file name
      String fileName = 'Samparka_Report.pdf';
      String filePath = '$exPath/$fileName';

      // Check if the file already exists, and if so, increment the filename
      int count = 1;
      while (await File(filePath).exists()) {
        filePath = '$exPath/Samparka_Report_${count}.pdf';
        count++;
      }

      final file = File(filePath);

      // Write PDF data to the file
      await file.writeAsBytes(await apiService.genReport(
        selectedFromDate!.toIso8601String(),
        selectedToDate!.toIso8601String(),
      ));

      // Print file path for confirmation
      print('PDF saved to: $filePath');

      isGenerating = false;

      // Show the dialog with the file name
      _showDownloadedDialog(filePath);

      //openDownloadedPDF(filePath);
      
      return true;
    } catch (e) {
      print('Error: $e');
      setState(() {
        isGenerating = false;
      });
      throw Exception('Failed to download report: $e');
    }
  }

  void _showDownloadedDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Report Downloaded"),
          content: Text(
            "The report has been downloaded to: \n$filePath",
          ),
          actions: [
            // Open button
            TextButton(
              onPressed: () async {
                final File file = File(filePath);
                if (await file.exists()) {
                  // File exists, proceed to open it
                  try {
                    try{
                      openDownloadedPDF(filePath);
                    }
                    catch (e) {
                      print('Error: $e');
                    }
                    // For Android 7.0+ devices, use FileProvider if necessary
                    final Uri fileUri = Uri.file(filePath); // Use Uri.file() to generate a proper URI
                    if (await canLaunch(fileUri.toString())) {
                      await launch(fileUri.toString());  // Launch the file URI
                    } else {
                      print("Couldn't open the file. No suitable app found.");
                    }
                  } catch (e) {
                    print('Error: $e');
                  }
                } else {
                  print("File does not exist at the specified path");
                }
              },
              child: Text("Open"),
            ),
            // Close dialog button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  void _showExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content: Text(
              "This app needs storage access to save files to your device. Please grant permission in settings."),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
                // Open app settings for the user to enable the permission
                openAppSettings();
              },
              child: Text("Open Settings"),
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
          title: Text("You are trying to download the report"),
          content: Text(
            "Do you want to download it?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();
                setState(() {
                });
                // Proceed to download the report
                await genReport();
                setState(() {
                });
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    print('object');
    //requestPermissions();
    Future.delayed(const Duration(milliseconds: 5000));
    print('object');
  }

  void _viewMeets(type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewReportMeetingsPage(type,selectedFromDate!.toIso8601String(),selectedToDate!.toIso8601String())),
    );
  }

  void _getReportPage() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getReportPage(apiService.UserId,selectedFromDate!.toIso8601String(),selectedToDate!.toIso8601String());
      setState(() {
        // Update the influencers list with the fetched data
        data = result;
        print('data: $data ${data[0]['Total_KR']}');
        influencerCount = data[0]['Total_GV'];
        influencerMet = data[0]['Met_GV'];
        activeTeamMembers = data[0]['Active_KR'];
        inactiveTeamMembers = data[0]['Total_KR'] - data[0]['Active_KR'];
        successfullMeetings = data[0]['Total_KR'];
        individualMeetings = data[0]['Individual'];
        SGM = data[0]['SGM'];
        programs = data[0]['Program'];
        baitek = data[0]['Baitek'];

      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching Report in Page: $e");
    }
  }

  // Method to handle bottom navigation item tap
  void _onNavItemTapped(int index) {
    if (index == 5) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InfluencersPage()),
      );
    } else if (index == 1) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TeamPage()),
      );
    } else if (index == 2) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MeetingPage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddInfluencerPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index; // Update the selected index for other tabs
      });
    }
  }

  // Function to show the DatePicker and update the selected date
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime initialDate = DateTime.now();
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        if (isFromDate) {
          selectedFromDate = picked;
        } else {
          selectedToDate = picked;
        }
        if ((selectedFromDate != null) && (selectedToDate != null) && (selectedToDate!.isAfter(selectedFromDate!))){
          _getReportPage();
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person, color: Color.fromRGBO(5, 50, 70, 1.0)), // Notification icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0, // Remove the app bar shadow
        title: Text('Samparka',style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: Color.fromRGBO(5, 50, 70, 1.0)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()), // Your help/feedback screen
              );
            },
          ),
          // Add the notification icon to the right side of the app bar
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromRGBO(5, 50, 70, 1.0)), // Notification icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Title and Download Button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Generate",
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
                        ],
                      ),
                    ),
                    //Download Button
                    Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: (selectedFromDate != null && selectedToDate != null && selectedToDate!.isAfter(selectedFromDate!))
                            ? LinearGradient(
                          colors: [
                            Color.fromRGBO(133, 1, 1, 1.0), // Red color
                            Color.fromRGBO(237, 62, 62, 1.0), // Lighter Red color
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                            : null, // No gradient if the condition is false
                        color: (selectedFromDate == null || selectedToDate == null || !selectedToDate!.isAfter(selectedFromDate!))
                            ? Colors.grey // Grey background if condition is false
                            : null, // No background color if gradient is applied
                      ),
                      child: TextButton(
                        onPressed: () async {
                          if ((selectedFromDate != null) && (selectedToDate != null) && (selectedToDate!.isAfter(selectedFromDate!))){
                            _acknowledgementDialog(context);
                            /*final call = Uri.parse('https://samparka.org/download_report_page/');
                        if (await canLaunchUrl(call)) {
                          launchUrl(call);
                        } else {
                          throw 'Could not launch $call';
                        }*/
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Download PDF',
                                style: TextStyle(
                                  fontSize: normFontSize,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                //Date selection
                Row(
                  children: [
                    // "From"
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Background color
                          borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                          border: Border.all(
                            color: Colors.grey.shade400, // Border color
                            width: 1, // Border width
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => _selectDate(context, true),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(12), // Remove default padding of TextButton
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedFromDate == null
                                    ? "From"
                                    : "${selectedFromDate!.toLocal()}".split(' ')[0],
                                style: TextStyle(color: Colors.grey.shade600,fontSize: normFontSize),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                    // "To"
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Background color
                          borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                          border: Border.all(
                            color: Colors.grey.shade400, // Border color
                            width: 1, // Border width
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => _selectDate(context, false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(14.0), // Remove default padding of TextButton
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedToDate == null
                                    ? "To"
                                    : "${selectedToDate!.toLocal()}".split(' ')[0],
                                style: TextStyle(color: Colors.grey.shade600,fontSize: normFontSize),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                //influencer and Team data
                if ((selectedFromDate != null) && (selectedToDate != null) && (selectedToDate!.isAfter(selectedFromDate!)))
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Influencer",
                              style: TextStyle(
                                fontSize: largeFontSize,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(5, 50, 70, 1.0),
                              ),
                              //textAlign: TextAlign.left,
                            ),
                            Container(
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(198, 198, 198, 1), // Background color
                                borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                border: Border.all(
                                  color: const Color.fromRGBO(198, 198, 198, 1.0), // Border color
                                  width: 1, // Border width
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                                children: [
                                  Row(
                                    children: [
                                      // First column: "Total" and its value
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center, // Centering content
                                          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                                          children: [
                                            Text(
                                              "Total",
                                              style: TextStyle(
                                                fontSize: normFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              influencerCount.toString(), // Replace with your 'total' variable
                                              style: TextStyle(
                                                fontSize: largeFontSize+5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 2,
                                        height: 50,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      // Second column: "Met" and its value
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center, // Centering content
                                          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                                          children: [
                                            Text(
                                              "Met",
                                              style: TextStyle(
                                                fontSize: normFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              influencerMet.toString(), // Replace with your 'met' variable
                                              style: TextStyle(
                                                fontSize: largeFontSize+5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Team",
                              style: TextStyle(
                                fontSize: largeFontSize,
                                fontWeight: FontWeight.w600,
                                color: const Color.fromRGBO(5, 50, 70, 1.0),
                              ),
                              //textAlign: TextAlign.left,
                            ),
                            Container(
                              padding: const EdgeInsets.all(14.0), // Padding around the container
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(198, 198, 198, 1), // Background color
                                borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                border: Border.all(
                                  color: const Color.fromRGBO(198, 198, 198, 1.0), // Border color
                                  width: 1, // Border width
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                                children: [
                                  // First row: "Active" and "Inactive" labels
                                  Row(
                                    children: [
                                      // First column: "Total" and its value
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center, // Centering content
                                          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                                          children: [
                                            Text(
                                              "Active",
                                              style: TextStyle(
                                                fontSize: normFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              activeTeamMembers.toString(), // Replace with your 'total' variable
                                              style: TextStyle(
                                                fontSize: largeFontSize+5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 2,
                                        height: 50,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      // Second column: "Met" and its value
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center, // Centering content
                                          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                                          children: [
                                            Text(
                                              "Inactive",
                                              style: TextStyle(
                                                fontSize: normFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              inactiveTeamMembers.toString(), // Replace with your 'met' variable
                                              style: TextStyle(
                                                fontSize: largeFontSize+5,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                //choose meeting and baitak
                if (selectedFromDate == null && selectedToDate == null)
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50,),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Grey background color
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            border: Border.all(color: Colors.grey), // Border color
                          ),
                          child: Text(
                            'No dates chosen',
                            style: TextStyle(
                              color: Colors.black, // Text color
                              fontSize: 18, // Text size
                              fontWeight: FontWeight.bold, // Text weight
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if ((selectedFromDate != null) && (selectedToDate != null) && (selectedToDate!.isAfter(selectedFromDate!)))
                  Column(
                    children: [
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Summary',style: TextStyle(fontWeight: FontWeight.bold,fontSize: largeFontSize+10,color: Color.fromRGBO(2, 40, 60, 1),decoration: TextDecoration.underline),),
                          ],
                        ),
                      ),
                      //Meeting Summary
                      Container(
                        width: MediaQuery.of(context).size.width-20,
                        padding: const EdgeInsets.all(16.0), // Padding around the container
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1, // Border width
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    width: MediaQuery.of(context).size.width*0.40,
                                    padding: const EdgeInsets.all(7.0),
                                    decoration: BoxDecoration(
                                      //color: Color.fromRGBO(255, 255, 255, 0.1), // Background color
                                      borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                      border: Border.all(
                                        color: Colors.grey.shade400, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: (){
                                        if(individualMeetings>0){
                                          _viewMeets('individual');
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Text('$individualMeetings',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: largeFontSize*1.85,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),),
                                          Text('Individual Meetings',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: normFontSize,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),textAlign: TextAlign.center,),
                                          //Text('data',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                    )
                                ),
                                SizedBox(width: 10),
                                Container(
                                    width: MediaQuery.of(context).size.width*0.40,
                                    padding: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      //color: Color.fromRGBO(255, 255, 255, 0.3), // Background color
                                      borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                      border: Border.all(
                                        color: Colors.grey.shade400, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: (){
                                        if(SGM>0){
                                          _viewMeets('sgm');
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Text('$SGM',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: largeFontSize*2,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),),
                                          Text('Small Group Meetings ',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: normFontSize,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),textAlign: TextAlign.center,),
                                          //Text('data',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                    )
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                    width: MediaQuery.of(context).size.width*0.40,
                                    padding: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      //color: Color.fromRGBO(255, 255, 255, 0.3), // Background color
                                      borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                      border: Border.all(
                                        color: Colors.grey.shade400, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: (){
                                        if(programs>0){
                                          _viewMeets('program');
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Text('$programs',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: largeFontSize*2,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),),
                                          Text('Programs',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: normFontSize,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),textAlign: TextAlign.center,),
                                        ],
                                      ),
                                    )
                                ),
                                SizedBox(width: 5),
                                Divider(),
                                SizedBox(width: 5),
                                Container(
                                    width: MediaQuery.of(context).size.width*0.40,
                                    padding: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      //color: Color.fromRGBO(255, 255, 255, 0.3), // Background color
                                      borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                      border: Border.all(
                                        color: Colors.grey.shade400, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    child: TextButton(
                                      onPressed: (){
                                        if(baitek>0){
                                          _viewMeets('baitak');
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Text('$baitek',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: largeFontSize*2,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),),
                                          Text('Baitaks',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: normFontSize,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),textAlign: TextAlign.center,),
                                        ],
                                      ),
                                    )
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                else if (selectedFromDate != null && selectedToDate != null)
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50,),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Grey background color
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            border: Border.all(color: Colors.grey), // Border color
                          ),
                          child: Text(
                            '\'To\' Date is greater than \'From\' Date',
                            style: TextStyle(
                              color: Colors.black, // Text color
                              fontSize: 18, // Text size
                              fontWeight: FontWeight.bold, // Text weight
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isGenerating)
            Positioned.fill(
              child: Container(
                height: MediaQuery.of(context).size.height+500,
                color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10), // Space between the indicator and text
                      const Text(
                        'Generating Report...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 1),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(10, 205, 165, 1.0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBottomNavItem(
                  label: "Influencers",
                  iconPath: 'assets/icon/add influencer.png',
                  isActive: _selectedIndex == 0,
                  onPressed: () => _onNavItemTapped(0),
                ),
                _buildBottomNavItem(
                  label: "Team",
                  iconPath: 'assets/icon/team.png',
                  isActive: _selectedIndex == 1,
                  onPressed: () => _onNavItemTapped(1),
                ),
                _buildBottomNavItem(
                  label: "Events",
                  iconPath: 'assets/icon/meeting.png',
                  isActive: _selectedIndex == 2,
                  onPressed: () => _onNavItemTapped(2),
                ),
                if(apiService.lvl>2)
                  _buildBottomNavItem(
                    label: "Report",
                    iconPath: 'assets/icon/report.png',  // Use the PNG file path
                    isActive: _selectedIndex == 3,
                    onPressed: () => _onNavItemTapped(3),
                  ),
                if(apiService.lvl<=2)
                  _buildBottomNavItem(
                    label: "Profile",
                    iconPath: 'assets/icon/report.png',  // Use the PNG file path
                    isActive: _selectedIndex == 5,
                    onPressed: () => _onNavItemTapped(5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required String label,
    required String iconPath,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color.fromRGBO(5, 50, 70, 1.0)
                      : Colors.white,
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    color: isActive ? Colors.white : const Color.fromRGBO(5, 50, 70, 1.0),
                    fit: BoxFit.contain,
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: isActive ? Colors.white : const Color.fromRGBO(5, 50, 70, 1.0),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
