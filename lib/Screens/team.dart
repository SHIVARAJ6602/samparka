import 'dart:io';

import 'package:flutter/material.dart';
import 'package:samparka/Screens/meeting.dart';
import 'package:samparka/Screens/my_team.dart';
import 'package:samparka/Screens/user_profile_page.dart';
import 'package:samparka/Screens/register_user.dart';
import 'package:samparka/Screens/settings.dart';
import 'Temp2.dart';
import 'add_influencer.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'gen_report.dart';
import 'home.dart';
import 'login.dart';
import 'API_TEST.dart'; //TaskListScreen()
import 'notifications.dart';
import 'view_influencers.dart';
import 'package:samparka/Service/api_service.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {

  // This keeps track of the selected index for the bottom navigation
  int _selectedIndex = 1;
  final apiService = ApiService();

  List<dynamic> members = [];
  List<dynamic> membersSearched = [];
  List<dynamic> supervisor = [];
  List<dynamic> lead = [];
  late List<dynamic> result = [];
  bool loading = true;
  bool isSearching = true;

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
        //MaterialPageRoute(builder: (context) => const TempPage2()),
        MaterialPageRoute(builder: (context) => const GenReportPage()),
      );
    } else if (index == 2) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MeetingPage()),
      );
    } else if (index == 0) {
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

  Future<void> fetchMembers() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.myTeam(0, 100);
      setState(() {
        print('members $result');
        // Update the influencers list with the fetched data
        members = result;
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  Future<void> fetchSupervisor() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.mySupervisor();
      //print('$result');
      setState(() {
        // Update the influencers list with the fetched data
        supervisor = result;
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  Future<void> fetchLead() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.myLead();
      //print('$result');
      setState(() {
        // Update the influencers list with the fetched data
        lead = result;
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  Future<void> search(String str) async {
    try {
      // Call the API service with the search query
      var mem = await apiService.searchGV(str);
      if (mem is List) {  // Check if inf is a List (data returned)
        setState(() {
          print("searched before assign:");
          membersSearched = [];
          print("result: $mem");
          membersSearched = mem;  // Assign the list data to membersSearched
          print("search: ");
        });
        setState(() {});
      } else if (mem == false) {  // If inf is false (no content or error)
        setState(() {
          membersSearched = [];  // Clear the list since no results were found
        });
      }
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    fetchSupervisor();
    if(apiService.lvl > 1) {
      fetchMembers();
    }
    if(apiService.lvl == 1){
      fetchLead();
    }
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.person, color: Color.fromRGBO(5, 50, 70, 1.0)), // Notification icon
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            backgroundColor: Colors.transparent, // Make the app bar background transparent
            elevation: 0, // Remove the app bar shadow
            title: Text('Samparka',style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
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
                              hintText: 'Search Member',
                              hintStyle: TextStyle(
                                fontSize: normFontSize,
                                fontWeight: FontWeight.normal,
                                color: const Color.fromRGBO(128, 128, 128, 1.0),
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
                          const SizedBox(height: 22),
                          if (!isSearching)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //My Supervisor
                                Text(
                                  'My Pramukh',
                                  style: TextStyle(
                                    fontSize: largeFontSize*1.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Container(
                                  decoration: BoxDecoration(
                                    //borderRadius: BorderRadius.circular(30),
                                    borderRadius: supervisor.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
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
                                      if (supervisor.isEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'No Supervisor Assigned',
                                              style: TextStyle(
                                                fontSize: largeFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      // If the list is not empty, build a ListView of InfluencerCards
                                      else
                                        Container(
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
                                                      // Check if profile_image exists and is not empty before passing it to NetworkImage
                                                      backgroundImage: supervisor[0]['profile_image'] != null && supervisor[0]['profile_image']!.isNotEmpty
                                                          ? MemoryImage(base64Decode(supervisor[0]['profile_image'].split(',')[1]))
                                                      //? NetworkImage(apiService.baseUrl.substring(0, 40) + supervisor[0]['profile_image'])
                                                          : null,
                                                      child: supervisor[0]['profile_image'] == null || supervisor[0]['profile_image']!.isEmpty
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
                                                            supervisor[0]['first_name']!, // Dynamic name
                                                            style: TextStyle(
                                                              fontSize: largeFontSize+6,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          Text(
                                                            supervisor[0]['last_name'], // Dynamic designation
                                                            style: TextStyle(
                                                              fontSize: smallFontSize,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          SizedBox(height: 1),
                                                          Text(
                                                            supervisor[0]['designation']??"", // Dynamic description
                                                            style: TextStyle(
                                                              fontSize: smallFontSize-2,
                                                              color: Colors.white,
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                //My Lead
                                if(apiService.lvl<2)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'My Lead',
                                        style: TextStyle(
                                          fontSize: largeFontSize*1.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromRGBO(5, 50, 70, 1.0),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Container(
                                        decoration: BoxDecoration(
                                          //borderRadius: BorderRadius.circular(30),
                                          borderRadius: lead.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
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
                                            if (lead.isEmpty)
                                              Container(
                                                padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'No lead Assigned',
                                                    style: TextStyle(
                                                      fontSize: largeFontSize,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            // If the list is not empty, build a ListView of InfluencerCards
                                            else
                                              Container(
                                                padding: const EdgeInsets.all(16),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // First Row: Profile Picture and Influencer Details
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: MediaQuery.of(context).size.width * 0.08,
                                                            backgroundColor: Colors.grey[200],
                                                            // Check if profile_image exists and is not empty before passing it to NetworkImage
                                                            backgroundImage: lead[0]['profile_image'] != null && lead[0]['profile_image']!.isNotEmpty
                                                                ? MemoryImage(base64Decode(lead[0]['profile_image'].split(',')[1]))
                                                            //? NetworkImage(apiService.baseUrl.substring(0, 40) + lead[0]['profile_image'])
                                                                : null,
                                                            child: lead[0]['profile_image'] == null || lead[0]['profile_image']!.isEmpty
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
                                                                  lead[0]['first_name'], // Dynamic name
                                                                  style: TextStyle(
                                                                    fontSize: largeFontSize+6,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  lead[0]['last_name'], // Dynamic designation
                                                                  style: TextStyle(
                                                                    fontSize: smallFontSize,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 1),
                                                                Text(
                                                                  lead[0]['designation'], // Dynamic description
                                                                  style: TextStyle(
                                                                    fontSize: smallFontSize-2,
                                                                    color: Colors.white,
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ]
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                //My team
                                if(apiService.lvl > 1)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'My Team',
                                        style: TextStyle(
                                          fontSize: largeFontSize*2.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromRGBO(5, 50, 70, 1.0),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Container(
                                        decoration: BoxDecoration(
                                          //borderRadius: BorderRadius.circular(30),
                                          borderRadius: members.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
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
                                            if (members.isEmpty)
                                              Container(
                                                padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'No Members Assigned',
                                                    style: TextStyle(
                                                      fontSize: largeFontSize,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            // If the list is not empty, build a ListView of InfluencerCards
                                            else
                                              Column(
                                                children: List.generate(
                                                  (members.length < 4) ? members.length : 3, // Display either all members or just 3
                                                      (index) {
                                                    final member = members[index]; // Access the member data
                                                    return Padding(
                                                      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                                      child: MemberCard(
                                                        id: member['id']!,
                                                        first_name: member['first_name']!,
                                                        last_name: member['last_name']!,
                                                        designation: member['designation']!,
                                                        profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                            ? member['profile_image']!
                                                            : '',
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),

                                            if (members.isNotEmpty)
                                            // View All Influencers Button
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const MyTeamPage()),
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'View all Members',
                                                      style: TextStyle(
                                                        fontSize: largeFontSize,
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
                                //Add new members
                                if(apiService.lvl > 2)
                                  Column(
                                    children: [
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
                                              MaterialPageRoute(builder: (context) => RegisterUserPage()),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.only(left: 0,right: 0, bottom: 10,top: 10), // Remove padding to fill the entire container
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Add New Member',
                                              style: TextStyle(
                                                fontSize: largeFontSize,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                //const SizedBox(height: 16),
                              ],
                            )
                          else
                            Column(
                              children: [Text('data')],
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),


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
        ),
        onWillPop: () async {
          // If searching, reset the search state and prevent the back action
          if (isSearching) {
            setState(() {
              isSearching = false; // Reset the searching state
            });
            return false; // Prevent back action if still searching
          }

          // Go to the previous screen directly if not searching
          Navigator.of(context).pop(); // Go to the previous screen

          return true; // Indicate that the back action is handled
        }

    );
  }

  Widget _buildBottomNavItem({
    required String label,
    required String iconPath,  // Change IconData to iconPath (a string representing the PNG path)
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
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
              fontSize: smallFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

}

class MemberCard extends StatelessWidget {
  final String id;
  final String first_name;
  final String last_name;
  final String designation;
  final String profileImage;

  const MemberCard({
    super.key,

    required this.first_name,
    required this.last_name,
    required this.designation,
    required this.profileImage,
    required this.id,

  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
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
            MaterialPageRoute(builder: (context) => UserProfilePage(id)),
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
                        fontSize: largeFontSize+6,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                    Text(
                      designation, // Dynamic designation
                      style: TextStyle(
                        fontSize: smallFontSize,
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
