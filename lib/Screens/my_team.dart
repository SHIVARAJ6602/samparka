import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samparka/Screens/team.dart';
import 'package:samparka/Screens/user_profile_page.dart';

import '../Service/api_service.dart';
import 'API_TEST.dart';
import 'gen_report.dart';
import 'home.dart';
import 'meeting.dart';

class MyTeamPage extends StatefulWidget {
  final String type;

  const MyTeamPage({super.key, required this.type});

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  final apiService = ApiService();

  int _selectedIndex = 1;
  List<dynamic> Members = [];
  List<dynamic> Gatanayaks = [];
  late List<dynamic> result;
  bool loading = true;


  @override
  void initState() {
    super.initState();
    if(widget.type == 'Gatanayaks'){
      fetchGatanayak();
    }
    else{
      fetchTeam();
    }
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
        Members = result;
      });
      loading = false;
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  Future<void> fetchGatanayak() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getGatanayak(apiService.UserId);
      setState(() {
        // Update the influencers list with the fetched data
        Members = result;
        //TeamMembers.add({'id':apiService.UserId,'first_name':'${apiService.first_name}(self)','last_name':apiService.last_name,'designation':apiService.designation,'profileImage':apiService.profileImage});
        print('Gatanayaks: $Members');
        loading = false;
      });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        title: widget.type=="Gatanayaks"? Text('My Gatanayak\'S'):Text('My Team'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(1),
            itemCount: Members.length,
            itemBuilder: (context, index) {
              final member = Members[index];
              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                child: MemberCard(
                  id: member['id']!,
                  first_name: member['first_name']!,
                  last_name: member['last_name']!,
                  designation: member['designation']??'Not Set',
                  profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                      ? member['profile_image']!
                      //? apiService.baseUrl.substring(0,40)+member['profile_image']!
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
                      CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 20, // Customize the radius of the activity indicator
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
          padding: const EdgeInsets.only(bottom: 16,top: 16), // Add padding to the content
          child: Row(
            children: [
              // Profile Picture (placeholder)
              Container(
                width: (MediaQuery.of(context).size.width * 0.80) / 4.3,  // 90% of screen width divided by 3 images
                height: (MediaQuery.of(context).size.width * 0.80) / 4.3,  // Fixed height for each image
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.grey[200],
                  boxShadow: [
                    if(profileImage.isNotEmpty)
                      BoxShadow(
                        color: Color.fromRGBO(5, 50, 70, 1.0).withOpacity(0.5), // Grey shadow color with opacity
                        spreadRadius: 1, // Spread radius of the shadow
                        blurRadius: 7, // Blur radius of the shadow
                        offset: Offset(0, 4), // Shadow position (x, y)
                      ),
                    if(profileImage.isEmpty)
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Grey shadow color with opacity
                        spreadRadius: 1, // Spread radius of the shadow
                        blurRadius: 3, // Blur radius of the shadow
                        offset: Offset(0, 4), // Shadow position (x, y)
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: (profileImage.isNotEmpty)
                      ? Image.network(
                    profileImage,  // Ensure the URL is encoded
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
                          child: Icon(Icons.error, color: Colors.grey[400],size: MediaQuery.of(context).size.width * 0.075),  // Display error icon
                        ),
                      );
                    },
                  )
                      : Icon(
                    Icons.person,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width * 0.14,
                  ),
                ),
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
