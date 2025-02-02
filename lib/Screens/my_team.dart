import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:samparka/Screens/team.dart';

import '../Service/api_service.dart';
import 'API_TEST.dart';
import 'gen_report.dart';
import 'home.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  final apiService = ApiService();

  int _selectedIndex = 1;
  List<dynamic> TeamMembers = [];
  late List<dynamic> result;
  bool loading = true;


  @override
  void initState() {
    super.initState();
    fetchTeam();
    Future.delayed(const Duration(milliseconds: 10000));
  }

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
    } else if (index == 1) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TeamPage()),
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

  // Define a function to fetch data
  Future<void> fetchTeam() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.myTeam(0, 100);
      setState(() {
        // Update the influencers list with the fetched data
        TeamMembers = result;
      });
      loading = false;
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      appBar: AppBar(
        title: Text('My Team'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(1),
            itemCount: TeamMembers.length,
            itemBuilder: (context, index) {
              final member = TeamMembers[index];
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                child: MemberCard(
                  first_name: member['first_name']!,
                  last_name: member['last_name']!,
                  designation: member['designation']!,
                  profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                      ? apiService.baseUrl.substring(0,40)+member['profile_image']!
                      : '',
                ),
              );
            },
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
                  label: "Add Influencer",
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

class MemberCard extends StatelessWidget {
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
          padding: const EdgeInsets.only(bottom: 16,top: 16), // Add padding to the content
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
