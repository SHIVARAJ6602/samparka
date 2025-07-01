import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:samparka/Screens/home.dart';
import 'package:samparka/Screens/schedule_meeting.dart';
import 'package:samparka/Screens/ProfilePage.dart';
import 'package:samparka/Screens/submit_report.dart';
import 'package:samparka/Screens/team.dart';
import 'package:samparka/Screens/view_influencers.dart';
import 'package:samparka/Screens/view_meeting.dart';

import '../Service/api_service.dart';
import 'API_TEST.dart';
import 'Temp2.dart';
import 'gen_report.dart';
import 'help.dart';
import 'login.dart';
import 'notifications.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});
  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  int _selectedIndex = 2;
  final apiService = ApiService();

  void _onNavItemTapped(int index) {
    if (index == 5) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else if (index == 4) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApiScreen()),
      );
    } else if (index == 3) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        //MaterialPageRoute(builder: (context) => const TempPage2()),
        MaterialPageRoute(builder: (context) => const GenReportPage()),
      );
    } else if (index == 1) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TeamPage()),
      );
    }else if (index == 0) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InfluencersPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index; // Update the selected index for other tabs
      });
    }
  }
  /****************menu**********************/
  // Text editing controllers for text fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController newUrlController = TextEditingController();

  late String username;
  late bool isAuthenticated;
  late String token;
  late int level;
  late String currentUrl;
  List<dynamic> influencers = [];
  List<dynamic> baitak = [];
  List<dynamic> programs = [];
  List<dynamic> smg = [];
  late List<dynamic> result;
  bool loading = true;
  @override
  void initState() {
    super.initState();

    //handleButtonPress();
    username = apiService.first_name;
    isAuthenticated = apiService.isAuthenticated;
    token = apiService.token;
    level = apiService.lvl;
    currentUrl = apiService.baseUrl;
    //fetchInfluencers();
    fetchMeeting('1');
    fetchMeeting('2');
    fetchMeeting('3');
    loading = false;
  }
  // State variables for radio buttons
  String? selectedRadio = 'url1';
  String? selectedMeetingType = 'baitak';

  // Function to handle button press logic
  void handleButtonPress() {
    setState(() {
      if (newUrlController.text.isNotEmpty) {
        currentUrl = newUrlController.text;
      } else {
        currentUrl = selectedRadio == 'url1' ? apiService.baseUrl1 : apiService.baseUrl2;
      }
      apiService.baseUrl = currentUrl;
      apiService.saveData();
    });

    // Logic for what should happen on button press
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('URL changed!'),
        content: Text('Current URL: $currentUrl'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Define a function to fetch data
  Future<bool> fetchInfluencers() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.homePage();
      setState(() {
        // Update the influencers list with the fetched data
        influencers = result;
      });
      return true;
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
    return false;
  }
  Future<bool> fetchMeeting(String MeetingTypeID) async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getEvents(MeetingTypeID);
      setState(() {
        // Update the influencers list with the fetched data
        if(MeetingTypeID == '1'){
          baitak = result;
        } else if(MeetingTypeID == '2'){
          programs = result;
        } else if(MeetingTypeID == '3'){
          smg = result;
        }
        print(result);
      });
      return true;
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
    return false;
  }

  /// ***************************************************

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    double squareSize = MediaQuery.of(context).size.width * 0.4;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: apiService.lvl > 2
            ? IconButton(
              icon: const Icon(Icons.person, color: Color.fromRGBO(5, 50, 70, 1.0)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            )
            : IconButton(
          icon: const Icon(Icons.home_outlined, color: Color.fromRGBO(5, 50, 70, 1.0)), // Notification icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InfluencersPage()),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
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
      /**************menu***********************/
      /*
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(60, 245, 200, 1.0),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Container(
              width: squareSize,
              height: squareSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.grey[200],
                boxShadow: [
                  if(apiService.profileImage != '')
                    BoxShadow(
                      color: Color.fromRGBO(5, 50, 70, 1.0).withOpacity(0.5), // Grey shadow color with opacity
                      spreadRadius: 1, // Spread radius of the shadow
                      blurRadius: 7, // Blur radius of the shadow
                      offset: Offset(0, 4), // Shadow position (x, y)
                    ),
                  if(apiService.profileImage == '')
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Grey shadow color with opacity
                      spreadRadius: 1, // Spread radius of the shadow
                      blurRadius: 3, // Blur radius of the shadow
                      offset: Offset(0, 4), // Shadow position (x, y)
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: (apiService.profileImage != '')
                    ? Image.network(
                  apiService.profileImage,  // Ensure the URL is encoded
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;  // Image loaded successfully
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white,  // Placeholder color for invalid image URLs
                      child: Center(
                        child: Icon(Icons.error, color: Colors.white),  // Display error icon
                      ),
                    );
                  },
                )
                    : Icon(
                  Icons.person,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.25,
                ),
              ),
            ),
            ListTile(
              title: Text('Username: $username'),
            ),
            ListTile(
              title: Text('Is Authenticated: $isAuthenticated'),
            ),
            ListTile(
              title: Text('Token: ${token.length > 20 ? token.substring(0, 20) : token}..'),
            ),
            ListTile(
              title: Text('User level: $level'),
            ),
            Divider(),
            ListTile(
              title: Text('API URL: ${currentUrl.length>28 ? currentUrl.substring(8,30): currentUrl}..'),
            ),
            // Submenu with radio buttons
            ExpansionTile(
              title: Text('Change API URL'),
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Radio<String>(
                        value: 'url1',
                        groupValue: selectedRadio,
                        onChanged: (value) {
                          setState(() {
                            selectedRadio = value;
                          });
                        },
                      ),
                      Text(apiService.baseUrl1.substring(8,24)),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Radio<String>(
                        value: 'url2',
                        groupValue: selectedRadio,
                        onChanged: (value) {
                          setState(() {
                            selectedRadio = value;
                          });
                        },
                      ),
                      Text(apiService.baseUrl2.substring(8,32)),
                    ],
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Radio<String>(
                        value: 'url3',
                        groupValue: selectedRadio,
                        onChanged: (value) {
                          setState(() {
                            selectedRadio = value;
                          });
                        },
                      ),
                      Text(apiService.baseUrl3.substring(8,30)),
                    ],
                  ),
                ),
                ListTile(
                  title: TextField(
                    controller: newUrlController,
                    decoration: InputDecoration(
                      labelText: 'Enter a new URL',
                    ),
                  ),
                ),
                ListTile(
                  title: ElevatedButton(
                    onPressed: handleButtonPress,
                    child: Text('Set url'),
                  ),
                ),
              ],
            ),
            //Divider(),
            // Perform action button

            Divider(),
            // Login button
            ListTile(
              title: ElevatedButton(
                onPressed: () {
                  // Navigate to the login page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Text('Login'),
              ),
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Logout'),
                      content: Text('Do you want to logout?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog if canceled
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Close the confirmation dialog first
                            Navigator.pop(context);

                            // Show loading dialog during logout
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Logging out...'),
                                content: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 5,  // You can adjust this to modify the thickness of the circle
                                    ),
                                  ),
                                ),
                              ),
                            );
                            await apiService.logout();
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          child: Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('LogOut'),
              ),
            ),
            ListTile(
              title: ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ApiScreen()),
                  );
                },
                child: Text('API'),
              ),
            ),
          ],
        ),
      ),
      */
      /***************************menu end*************************************/
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // + New Meeting
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "My Team",
                                  style: TextStyle(
                                    fontSize: largeFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "Events",
                                  style: TextStyle(
                                    fontSize: largeFontSize+20,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width*0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: const Color.fromRGBO(5, 50, 70, 1.0),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                    MaterialPageRoute(builder: (context) => const ScheduleMeetingPage()), // Replace with your page
                                );

                                if (result != null && result) {
                                  // The result is true, meaning the page needs to be reloaded
                                  initState();
                                  setState(() {
                                    // Trigger a state change to reload the previous page's content


                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(1),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '+ New Event',
                                      style: TextStyle(
                                        fontSize: largeFontSize,
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
                      //Approve and assign
                      if(apiService.lvl >= 11)
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            if (baitak.isEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 1),
                                  // approval Cards
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal, // Horizontal scrolling
                                    child: Row(
                                      children: List.generate(2, (index) {
                                        //final influencer = influencers[index]; // Access the influencer data for each item
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 1,right: 8,top: 8,bottom: 8), // Adjust horizontal padding
                                          child: Container(
                                            width: MediaQuery.of(context).size.width*0.75,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                              gradient: const LinearGradient(
                                                begin: Alignment.centerRight,
                                                end: Alignment.centerLeft,
                                                colors: [
                                                  Color.fromRGBO(60, 170, 145, 1.0),
                                                  Color.fromRGBO(2, 40, 60, 1),
                                                ],
                                              ),
                                            ),
                                            child: ActionCard(
                                              id: 'BT0000001',
                                              type: '1',
                                              name: 'Event Name',
                                              date: 'xx/xx/xxxx',
                                              time: 'xx:xx:xx',
                                              location: 'Location,Location',
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState((){
                                          selectedMeetingType = "baitak";
                                        });
                                      },
                                      child: Text(
                                        "Baitaks",
                                        style: selectedMeetingType == "baitak"
                                            ? TextStyle(color: const Color.fromRGBO(5, 50, 70, 1.0),fontWeight: FontWeight.w600, fontSize: largeFontSize,decoration: TextDecoration.underline)
                                            : TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: largeFontSize),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState((){
                                          selectedMeetingType = "program";
                                        });
                                      },
                                      child: Text(
                                        "Programs",
                                        style: selectedMeetingType == "program"
                                            ? TextStyle(color: const Color.fromRGBO(5, 50, 70, 1.0),fontWeight: FontWeight.w600, fontSize: largeFontSize,decoration: TextDecoration.underline)
                                            : TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: largeFontSize),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState((){
                                          selectedMeetingType = "smg";
                                        });
                                      },
                                      child: Text(
                                        "Small Group\nEvents",
                                        style: selectedMeetingType == "smg"
                                            ? TextStyle(color: const Color.fromRGBO(5, 50, 70, 1.0),fontWeight: FontWeight.w600, fontSize: normFontSize,decoration: TextDecoration.underline,)
                                            : TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: normFontSize),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.teal,thickness: 1),
                      //scheduled Meeting Title
                      //Row(children: [Text('Scheduled',style: TextStyle(fontSize: largeFontSize,color: const Color.fromRGBO(5, 50, 70, 1.0),fontWeight: FontWeight.w600))],),
                      //Baitak
                      if(selectedMeetingType == 'baitak')
                        Container(
                        child: Column(
                          children: [
                            Row(children: [Text("Baitaks",style: TextStyle(fontSize: largeFontSize+20,fontWeight: FontWeight.w600,color: const Color.fromRGBO(5, 50, 70, 1.0),),),],),
                            //scheduled meetings
                            const SizedBox(height: 1),
                            // meeting Cards
                            Container(
                              child: Column(
                                children: [
                                  // If the list is empty, show a message
                                  if (loading)
                                    Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.blue,
                                      ),
                                    )
                                  else
                                    if (baitak.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'No Event Scheduled',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Column(
                                        children: List.generate(baitak.length, (index) {
                                          final meeting = baitak[index]; // Access the meeting data for each item
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
                                            child: MeetingCard(
                                              title: meeting['title']!,
                                              typeId: '1',
                                              description: meeting['description']!,
                                              dateTime: meeting['meeting_datetime']!,
                                              id: meeting['id']!,
                                              data: meeting,
                                            ),
                                          );
                                        }),
                                      ),

                                  if (influencers.isNotEmpty)
                                  // View All Influencers Button
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ViewInfluencersPage(apiService.UserId)),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'View all Influencers',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Image.asset(
                                            'assets/icon/arrow.png',
                                            color: Colors.white,
                                            width: 12,
                                            height: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //scheduled Meeting Title
                      //Row(children: [Text('Scheduled',style: TextStyle(fontSize: largeFontSize,color: const Color.fromRGBO(5, 50, 70, 1.0),fontWeight: FontWeight.w600))],),
                      if(selectedMeetingType == 'program')
                        Container(
                        child: Column(
                          children: [
                            Row(children: [Text("Programs",style: TextStyle(fontSize: largeFontSize+20,fontWeight: FontWeight.w600,color: const Color.fromRGBO(5, 50, 70, 1.0),),),],),
                            //scheduled meetings
                            const SizedBox(height: 1),
                            // meeting Cards
                            Container(
                              /*decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(60, 170, 145, 1.0),
                              Color.fromRGBO(2, 40, 60, 1),
                            ],
                          ),
                        ),*/
                              child: Column(
                                children: [
                                  // If the list is empty, show a message
                                  if (loading)
                                    Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.blue,
                                      ),
                                    )
                                  else
                                    if (programs.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'No Event Scheduled',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Column(
                                        children: List.generate(programs.length, (index) {
                                          final meeting = programs[index]; // Access the meeting data for each item
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
                                            child: MeetingCard(
                                              title: meeting['title']!,
                                              typeId: '2',
                                              description: meeting['description']!,
                                              dateTime: meeting['meeting_datetime']!,
                                              id: meeting['id']!,
                                              data: meeting,
                                            ),
                                          );
                                        }),
                                      ),

                                  if (influencers.isNotEmpty)
                                  // View All Influencers Button
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ViewInfluencersPage(apiService.UserId)),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'View all Influencers',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Image.asset(
                                            'assets/icon/arrow.png',
                                            color: Colors.white,
                                            width: 12,
                                            height: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      //scheduled Meeting Title
                      //Row(children: [Text('Scheduled',style: TextStyle(fontSize: largeFontSize,color: const Color.fromRGBO(5, 50, 70, 1.0),fontWeight: FontWeight.w600))],),
                      if(selectedMeetingType == 'smg')
                        Container(
                        child: Column(
                          children: [
                            Row(children: [Text("Small Group Events",style: TextStyle(fontSize: largeFontSize+20,fontWeight: FontWeight.w600,color: const Color.fromRGBO(5, 50, 70, 1.0),),),],),
                            //scheduled meetings
                            const SizedBox(height: 1),
                            // meeting Cards
                            Container(
                              child: Column(
                                children: [
                                  // If the list is empty, show a message
                                  if (loading)
                                    Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.blue,
                                      ),
                                    )
                                  else
                                    if (smg.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'No Event Scheduled',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Column(
                                        children: List.generate(smg.length, (index) {
                                          final meeting = smg[index]; // Access the meeting data for each item
                                          return Padding(
                                            padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
                                            child: MeetingCard(
                                              title: meeting['title']!,
                                              typeId: '3',
                                              description: meeting['description']!,
                                              dateTime: meeting['meeting_datetime']!,
                                              id: meeting['id']!,
                                              data: meeting,
                                            ),
                                          );
                                        }),
                                      ),
                                  if (influencers.isNotEmpty)
                                  // View All Influencers Button
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ViewInfluencersPage(apiService.UserId)),
                                        );
                                       },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'View all Influencers',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Image.asset(
                                            'assets/icon/arrow.png',
                                            color: Colors.white,
                                            width: 12,
                                            height: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),

      // Custom Bottom Navigation Bar with padding around it
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16,top: 1),  // Add padding around the bottom navigation bar
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
                  iconPath: 'assets/icon/add influencer.png',  // Use the PNG file path
                  isActive: _selectedIndex == 0,
                  onPressed: () => _onNavItemTapped(0),
                ),
                _buildBottomNavItem(
                  label: "Team",
                  iconPath: 'assets/icon/team.png',  // Use the PNG file path
                  isActive: _selectedIndex == 1,
                  onPressed: () => _onNavItemTapped(1),
                ),
                _buildBottomNavItem(
                  label: "Events",
                  iconPath: 'assets/icon/meeting.png',  // Use the PNG file path
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
                /*_buildBottomNavItem(
                  label: "API",
                  iconPath: 'assets/icon/report.png',  // Use the PNG file path
                  isActive: _selectedIndex == 4,
                  onPressed: () => _onNavItemTapped(4),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required String label,
    required String iconPath,  // Change IconData to iconPath (a string representing the PNG path)
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
                width: 45, // Inner container size
                height: 45, // Inner container size
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color.fromRGBO(5, 50, 70, 1.0)
                      : Colors.white, // Optional: Background color of the inner container
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    color: isActive ? Colors.white : const Color.fromRGBO(5, 50, 70, 1.0),
                    fit: BoxFit.contain, // Ensures image scales to fit within inner container
                    width: 30, // Image width
                    height: 30, // Image height
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
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

class ActionCard extends StatelessWidget {
  final String id;
  final String type;
  final String name;
  final String date;
  final String time;
  final String location;

  const ActionCard({
    super.key,
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.id, required this.type,
  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Container(
      padding: const EdgeInsets.all(16),
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
                    name,  // Dynamic name
                    style: TextStyle(
                      fontSize: largeFontSize + 6,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    date,  // Dynamic designation
                    style: TextStyle(
                      fontSize: smallFontSize,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    time,  // Dynamic description
                    style: TextStyle(
                      fontSize: smallFontSize - 2,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1),
                  Text(
                    location,  // Dynamic hashtags
                    style: TextStyle(
                      fontSize: smallFontSize - 2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5),
            // Second Column: buttons
            Container(
              //width: MediaQuery.of(context).size.width ,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromRGBO(5, 50, 70, 1.0),
                    ),
                    child: TextButton(
                      onPressed: () {
                        /*
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SubmitReportPage(id,'1')),
                        );*/
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Submit Report',
                              style: TextStyle(
                                fontSize: smallFontSize-2,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width*0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromRGBO(133, 1, 1, 1.0),
                          Color.fromRGBO(237, 62, 62, 1.0),
                        ],
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Cancel Event',
                              style: TextStyle(
                                fontSize: smallFontSize-2,
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
            ),
            // Space between the two rows
          ],
        ),
      ),


    );
  }

}

class MeetingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  final String typeId;
  final String description;
  final String dateTime;
  final String id;

  const MeetingCard({
    super.key,
    required this.title,
    required this.description,
    required this.id,
    required this.dateTime,
    required this.data, required this.typeId,
  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; // 16
    double largeFontSize = normFontSize + 4; // 20
    double smallFontSize = normFontSize - 2;

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

    return Container(
      padding: EdgeInsets.all(4),
      width: MediaQuery.of(context).size.width * 0.93,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Color.fromRGBO(60, 170, 145, 1.0),
            Color.fromRGBO(2, 40, 60, 1),
          ],
        ),
      ),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ViewEventPage(id, data, typeId)),
          );
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 1.0), // Adjusted padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Added to space out the content
            children: [
              // Left Column: Meeting details
              Container(
                width: MediaQuery.of(context).size.width * 0.50, // Adjust width for details
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,  // Dynamic name
                      style: TextStyle(
                        fontSize: largeFontSize + 6,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Date: ',  // Dynamic description
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: smallFontSize,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          formatDate(dateTime),  // Dynamic description
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: smallFontSize,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Time: ',  // Dynamic description
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: smallFontSize,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          formatTime(dateTime),  // Dynamic description
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: smallFontSize,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          'Location: ',  // Dynamic description
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: smallFontSize,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          data['venue'],  // Dynamic description
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: smallFontSize,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Right Column: Buttons
              Container(
                width: MediaQuery.of(context).size.width * 0.315, // Adjust width for buttons
                child: Column(
                  children: [
                    if(data['status'] == 'scheduled')
                    Container(
                      width: MediaQuery.of(context).size.width * 0.30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SubmitReportPage(id,typeId,data)),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Center(
                          child: Text(
                            'Submit Report',
                            style: TextStyle(
                              fontSize: smallFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    if(data['status'] == 'scheduled')
                    Container(
                      width: MediaQuery.of(context).size.width * 0.30     ,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromRGBO(133, 1, 1, 1.0),
                            Color.fromRGBO(237, 62, 62, 1.0),
                          ],
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Center(
                          child: Text(
                            'Cancel Event',
                            style: TextStyle(
                              fontSize: smallFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
