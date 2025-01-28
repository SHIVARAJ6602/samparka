import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:samparka/Screens/home.dart';
import 'package:samparka/Screens/schedule_meeting.dart';
import 'package:samparka/Screens/submit_report.dart';
import 'package:samparka/Screens/team.dart';
import 'package:samparka/Screens/view_influencers.dart';

import '../Service/api_service.dart';
import 'API_TEST.dart';
import 'gen_report.dart';
import 'login.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});
  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  int _selectedIndex = 2;
  final apiService = ApiService();

  void _onNavItemTapped(int index) {
    if (index == 4) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApiScreen()),
      );
    } else if (index == 3) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
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
    fetchInfluencers();
    loading = false;
  }
  // State variables for radio buttons
  String? selectedRadio = 'url1';

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

  /// ***************************************************

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar background transparent
        elevation: 0, // Remove the app bar shadow
        title: Text(apiService.first_name),
        /*leading: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.login, color: Color.fromRGBO(5, 50, 70, 1.0)), // Back button icon
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            /*Text(
              'name: ${apiService.userName}', // Display the name after the login button
              style: const TextStyle(
                color: Color.fromRGBO(5, 50, 70, 1.0),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),*/
          ],
        ),*/
        actions: [
          // Add the notification icon to the right side of the app bar
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromRGBO(5, 50, 70, 1.0)), // Notification icon
            onPressed: () {
              // Handle the notification icon tap here (you can add navigation or other actions)
              print('Notifications tapped');
            },
          ),
        ],
      ),
      /**************menu***********************/
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
            CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.15,
              backgroundColor: Colors.grey[200],
              backgroundImage: apiService.profile_image.isNotEmpty ? MemoryImage(base64Decode(apiService.profile_image.split(',')[1])) : null, // Use NetworkImage here
              child: apiService.profile_image.isEmpty
                  ? Icon(
                Icons.person,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.14,
              )
                  : null,
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
                      Text(apiService.baseUrl1.substring(8,30)),
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
                                  "Meetings",
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ScheduleMeetingPage()),
                                );
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
                                      '+ New meeting',
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
                      if(apiService.lvl > 2)
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            if (influencers.isEmpty)
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
                                              name: 'Meeting Name',
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
                      //scheduled Meeting Title
                      Row(children: [Text('Scheduled',style: TextStyle(fontSize: largeFontSize,color: const Color.fromRGBO(5, 50, 70, 1.0),fontWeight: FontWeight.w600))],),
                      Row(children: [Text("Meetings",style: TextStyle(fontSize: largeFontSize+20,fontWeight: FontWeight.w600,color: const Color.fromRGBO(5, 50, 70, 1.0),),),],),
                      //scheduled meetings
                      const SizedBox(height: 1),
                      // meeting Cards
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
                              if (influencers.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No Meeting Scheduled',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: influencers.length, // The number of items in your data list
                                  itemBuilder: (context, index) {
                                    final influencer = influencers[index]; // Access the influencer data for each item
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                      child: MeetingCard(
                                        name: influencer['fname']!,
                                        designation: influencer['designation']!,
                                        description: influencer['description']!,
                                        hashtags: influencer['hashtags']!,
                                        profileImage: influencer['profile_image'] != null && influencer['profile_image']!.isNotEmpty
                                            ? apiService.baseUrl.substring(0,40)+influencer['profile_image']!
                                            : '',
                                      ),
                                    );
                                  },
                                ),

                            if (influencers.isNotEmpty)
                            // View All Influencers Button
                              TextButton(
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ViewInfluencersPage()),
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
                  label: "Influencer",
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
                  label: "Meeting",
                  iconPath: 'assets/icon/meeting.png',  // Use the PNG file path
                  isActive: _selectedIndex == 2,
                  onPressed: () => _onNavItemTapped(2),
                ),
                _buildBottomNavItem(
                  label: "Report",
                  iconPath: 'assets/icon/report.png',  // Use the PNG file path
                  isActive: _selectedIndex == 3,
                  onPressed: () => _onNavItemTapped(3),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SubmitReportPage()),
                        );
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
                              'Cancel Meeting',
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
  final String name;
  final String designation;
  final String description;
  final String hashtags;
  final String profileImage;

  const MeetingCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags, required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0), // Container padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          print('object');
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 0,right: 0,bottom: 8,top: 8), // Add padding to the content
          child: Row(
            children: [
              // Profile Picture (placeholder)
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.08,
                backgroundColor: Colors.grey[200],
                backgroundImage: profileImage.isNotEmpty ? MemoryImage(base64Decode(profileImage.split(',')[1])) : null, // Use NetworkImage here
                child: profileImage.isEmpty
                    ? Icon(
                  Icons.person,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.14,
                )
                    : null,
              ),
              SizedBox(width: 16),
              // Influencer Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name, // Dynamic name
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                    Text(
                      designation, // Dynamic designation
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                    Text(
                      description, // Dynamic designation
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                    Text(
                      hashtags, // Dynamic designation
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 1),
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