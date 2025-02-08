import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:samparka/Screens/meeting.dart';
import 'package:samparka/Screens/my_team.dart';
import 'package:samparka/Screens/team.dart';
import 'add_influencer.dart';
import 'gen_report.dart';
import 'influencer_profile.dart';
import 'login.dart';
import 'API_TEST.dart'; //TaskListScreen()
import 'view_influencers.dart';
import 'package:samparka/Service/api_service.dart';

class InfluencersPage extends StatefulWidget {
  const InfluencersPage({super.key});

  @override
  _InfluencersPageState createState() => _InfluencersPageState();
}

class _InfluencersPageState extends State<InfluencersPage> {
  // This keeps track of the selected index for the bottom navigation
  int _selectedIndex = 0;
  final apiService = ApiService();

  // Method to handle bottom navigation item tap
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
    } else if (index == 2) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MeetingPage()),
      );
    } else if (index == 1) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TeamPage()),
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
  List<dynamic> unApprovedInfluencers = [];
  late List<dynamic> result;
  bool loading = true;
  bool assign = false;

  List<dynamic> TeamMembers = [];
  //List<dynamic> ApproveMember = [];
  Map<String, dynamic> ApproveMember = {};
  int selectedMemberIndex = -1;
  int? selectedIndex;

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
    getUnapprovedProfile();
    fetchTeam();
    setState(() {});
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

  Future<bool> getUnapprovedProfile() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.get_unapproved_profiles();
      if (result.isNotEmpty) {
        setState(() {
          // Update the influencers list with the fetched data
          unApprovedInfluencers = result;
        });
      } else {
        setState(() {
          unApprovedInfluencers = [];  // Clear the list if result is empty
        });
      }


      return true;
    } catch (e) {
      unApprovedInfluencers = [];
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
    setState(() {});
    return false;
  }

  Future<void> fetchTeam() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.myTeam(0, 100);
      setState(() {
        // Update the influencers list with the fetched data
        TeamMembers = result;
        TeamMembers.add({'id':apiService.UserId,'first_name':'${apiService.first_name}(self)','last_name':apiService.last_name,'designation':apiService.designation,'profileImage':apiService.profile_image});

      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  /******************************************************/

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
              child: Container(
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text(
                            'Settings:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.13,
                      backgroundColor: Colors.grey[400],
                      backgroundImage: apiService.profile_image.isNotEmpty ? MemoryImage(base64Decode(apiService.profile_image.split(',')[1])) : null, // Use NetworkImage here
                      child: apiService.profile_image.isEmpty
                          ? Icon(
                        Icons.person,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width * 0.14,
                      )
                          : null,
                    ),
                  ],
                ),
              )
            ),
            ListTile(
              title: Text('Username: $username'),
            ),
            ListTile(
              title: Text('City: ${apiService.city}'),
            ),
            ListTile(
              title: Text('District: ${apiService.district}'),
            ),
            ListTile(
              title: Text('State: ${apiService.state}'),
            ),
            ListTile(
              title: Text('Is Authenticated: $isAuthenticated'),
            ),
            ListTile(
              title: Text('User level: $level'),
            ),
            ListTile(
              title: Text('Token: ${token.length > 20 ? token.substring(0, 20) : token}..'),
            ),
            Divider(),
            ListTile(
              title: Text('API URL: ${currentUrl}..'),
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
      /***************************menu end*************************************/
      body: Stack(
        children: [
          // Main content inside a SingleChildScrollView
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //const SizedBox(height: 50),
                      // Search Bar
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromRGBO(217, 217, 217, 1.0),
                          hintText: 'Search Influencer',
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color.fromRGBO(128, 128, 128, 1.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromRGBO(60, 245, 200, 1.0),
                                    Color.fromRGBO(2, 40, 60, 1),
                                  ],
                                ),
                              ),
                              child: const Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      //Approve and assign
                      if(apiService.lvl > 2)
                      Column(
                        children: [
                          const SizedBox(height: 22),
                          if (unApprovedInfluencers.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // approval & assign Influencers Title
                                Text(
                                  'Approval & Assign',
                                  style: TextStyle(
                                    fontSize: largeFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                ),
                                Text(
                                  'Influencers',
                                  style: TextStyle(
                                    fontSize: largeFontSize*2.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                // approval Cards
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal, // Horizontal scrolling
                                  child: Row(
                                    children: List.generate(unApprovedInfluencers.length, (index) {
                                      final influencer = unApprovedInfluencers[index]; // Access the influencer data for each item
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 1, right: 8, top: 8, bottom: 8), // Adjust horizontal padding
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.75,
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
                                          child: ApprovalCard(
                                            name: influencer['fname']!,
                                            designation: influencer['designation']!,
                                            description: influencer['description']!,
                                            hashtags: influencer['hashtags']!,
                                            imageUrl: influencer['profile_image'] != null && influencer['profile_image']!.isNotEmpty
                                                ? apiService.baseUrl.substring(0, 40) + influencer['profile_image']!
                                                : '',
                                            onPress: () {
                                              setState(() {
                                                selectedIndex = index;
                                                ApproveMember = unApprovedInfluencers[index];
                                                print(ApproveMember);
                                                assign = true;
                                              });
                                              print('Selected index: $selectedIndex'); // Print selected index
                                            },
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
                      // Recently Assigned Influencers Title
                      const Text(
                        'Recently Assigned',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(5, 50, 70, 1.0),
                        ),
                      ),
                      const Text(
                        'Influencers',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(5, 50, 70, 1.0),
                        ),
                      ),
                      const SizedBox(height: 1),
                      // Influencer Cards
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
                                      'No Influencer Assigned',
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
                                      child: InfluencerCard(
                                        id: influencer['id']!,
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

                      const SizedBox(height: 20),
                      Container(
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddInfluencerPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(left: 0,right: 0, bottom: 10,top: 10), // Remove padding to fill the entire container
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                          ),
                          child: const Center(
                            child: Text(
                              'Add New Influencer',
                              style: TextStyle(
                                fontSize: 23,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      //const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if(assign)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.65,
                    width: MediaQuery.of(context).size.width * 0.9,
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
                    child: Stack(
                      children: [
                        // Main content here (Profile, button, etc.)
                        Padding(
                          padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // First Row: Profile Picture and Influencer Details
                              Row(
                                children: [
                                  // Profile Picture (placeholder)
                                  /*CircleAvatar(
                                    radius: MediaQuery.of(context).size.width * 0.10,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: ApproveMember.isNotEmpty? FileImage(File(ApproveMember['profile_image'])): null,
                                    child: ApproveMember.isEmpty
                                        ? Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.width * 0.14,
                                    )
                                        : null,
                                  ),*/
                                  SizedBox(width: 16),
                                  // Influencer Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ApproveMember['fname']??'', // Dynamic name
                                          style: TextStyle(
                                            fontSize: largeFontSize + 6,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              ApproveMember['designation']??'', // Dynamic designation
                                              style: TextStyle(
                                                fontSize: smallFontSize,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            SizedBox(
                                                width: 2,
                                                child: Container(
                                                  width: 1,
                                                  height: smallFontSize,
                                                  color: Colors.white,
                                                )),
                                            SizedBox(width: 5),
                                            Text(
                                              'shreni', // Dynamic designation
                                              style: TextStyle(
                                                fontSize: smallFontSize,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 1),
                                        Text(
                                          ApproveMember['description']??'', // Dynamic description
                                          style: TextStyle(
                                            fontSize: smallFontSize - 2,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 1),
                                        Text(
                                          'hashtags', // Dynamic hashtags
                                          style: TextStyle(
                                            fontSize: smallFontSize - 2,
                                            color: Colors.teal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // List of Team Members (Selectable)
                              Center(
                                child: Container(
                                  height: MediaQuery.of(context).size.height * 0.38,
                                  width: MediaQuery.of(context).size.width * 0.85,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(1),
                                    itemCount: TeamMembers.length,
                                    itemBuilder: (context, index) {
                                      final member = TeamMembers[index];
                                      bool isSelected = selectedMemberIndex == index; // Check if this member is selected
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedMemberIndex = isSelected ? -1 : index; // Toggle selection
                                            });
                                          },
                                          child: MemberCard(
                                            first_name: member['first_name']!,
                                            last_name: member['last_name']!,
                                            designation: member['designation']!,
                                            profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                ? apiService.baseUrl.substring(0, 40) + member['profile_image']!
                                                : '',
                                            isSelected: isSelected,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Spacer to push the button to the bottom
                              Expanded(child: SizedBox()),

                              // Second Row: Approval Button
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0), // 10px margin from bottom
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center, // Align button to the center
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
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
                                        onPressed: () async {
                                          // Handle the approval logic here
                                          print('Selected Member Index: $selectedMemberIndex');
                                          if(selectedMemberIndex>-1) {
                                            print(ApproveMember['id']);
                                            print(TeamMembers[selectedMemberIndex]['id']);
                                            await apiService.approveGanyavyakthi(ApproveMember['id'],TeamMembers[selectedMemberIndex]['id']);
                                            await getUnapprovedProfile();
                                            setState((){
                                              assign = false;
                                            });
                                          }

                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(10),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Approve and Assign',
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
                              ),
                              //assign cancel cutton
                              TextButton(
                                onPressed: () async {
                                  setState((){
                                    assign = false;
                                    selectedMemberIndex = -1;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(1),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center, // Center align the row content
                                        children: [
                                          // Text and Icon Row
                                          Text(
                                            'Cancel', // The cancel text
                                            style: TextStyle(
                                              fontSize: smallFontSize,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 8), // A small gap between the text and the icon
                                          Icon(
                                            Icons.cancel, // Cancel icon
                                            color: Colors.white, // Set the icon color to white
                                            size: smallFontSize, // You can adjust the size of the icon here
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Circular "L" at the top right
                        Positioned(
                          top: 15,
                          right: 15,
                          child: Container(
                            width: 30,  // Diameter of the circle
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.blue,  // Blue background color
                              shape: BoxShape.circle,  // Make it a circle
                            ),
                            child: Center(
                              child: Text(
                                'L1',  // The letter inside the circle
                                style: TextStyle(
                                  fontSize: smallFontSize,  // Font size for "L"
                                  color: Colors.white,  // White color for the letter
                                  fontWeight: FontWeight.bold,
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
            ),
          if(loading)
            Positioned.fill(
              child: Container(
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
                        'Loading...',
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



class InfluencerCard extends StatelessWidget {
  final String id;
  final String name;
  final String designation;
  final String description;
  final String hashtags;
  final String profileImage;

  const InfluencerCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags,
    required this.profileImage,
    required this.id,
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InfluencerProfilePage(id)),
          );
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
                backgroundImage: profileImage.isNotEmpty ? MemoryImage(base64Decode(profileImage.split(',')[1])) : null,
                //backgroundImage: profileImage.isNotEmpty ? MemoryImage(base64Decode(profileImage.split(',')[1])) : null, // Use NetworkImage here
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

class ApprovalCard extends StatelessWidget {
  final String name;
  final String designation;
  final String description;
  final String hashtags;
  final String imageUrl;
  final VoidCallback onPress; // Callback to handle button press

  const ApprovalCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags,
    required this.imageUrl,
    required this.onPress, // Handle button press in parent
  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize + 4; //20
    double smallFontSize = normFontSize - 2; //14

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row: Profile Picture and Influencer Details
          Row(
            children: [
              // Profile Picture (placeholder)
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.08,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageUrl.isNotEmpty ? MemoryImage(base64Decode(imageUrl.split(',')[1])) : null,
                child: imageUrl.isEmpty
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
                        fontSize: largeFontSize + 6,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      designation, // Dynamic designation
                      style: TextStyle(
                        fontSize: smallFontSize,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      description, // Dynamic description
                      style: TextStyle(
                        fontSize: smallFontSize - 2,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1),
                    Text(
                      hashtags, // Dynamic hashtags
                      style: TextStyle(
                        fontSize: smallFontSize - 2,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8), // Space between the two rows
          // Second Row: Approval Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Align button to the end
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
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
                  onPressed: onPress, // Trigger the parent function
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Approve and Assign',
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
        ],
      ),
    );
  }
}

class AssignCard extends StatelessWidget {
  final String name;
  final String designation;
  final String description;
  final String hashtags;
  final String imageUrl;

  const AssignCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags, required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row: Profile Picture and Influencer Details
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.08,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null, // Use NetworkImage here
                child: imageUrl.isEmpty
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
                        fontSize: largeFontSize+6,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      designation, // Dynamic designation
                      style: TextStyle(
                        fontSize: smallFontSize,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      description, // Dynamic description
                      style: TextStyle(
                        fontSize: smallFontSize-2,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1),
                    Text(
                      hashtags, // Dynamic hashtags
                      style: TextStyle(
                        fontSize: smallFontSize-2,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8), // Space between the two rows
          // Second Row: Approval Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Align button to the end
            children: [
              Container(
                width: MediaQuery.of(context).size.width*0.65,
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
                          'Approve and Assign',
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
        ],
      ),
    );
  }

}

class MemberCard extends StatelessWidget {
  final String first_name;
  final String last_name;
  final String designation;
  final String profileImage;
  final bool isSelected;

  const MemberCard({
    super.key,

    required this.first_name,
    required this.last_name,
    required this.designation,
    required this.profileImage,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.green[200] : Colors.white,
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(0), // Container padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[200] : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16,top: 16,left: 8,right: 8), // Add padding to the content
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
                      '$first_name $last_name', // Dynamic name
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

