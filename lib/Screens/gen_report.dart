import 'package:flutter/material.dart';
import 'add_influencer.dart';
import 'l1home.dart';

class GenReportPage extends StatefulWidget {
  const GenReportPage({super.key});

  @override
  _GenReportPageState createState() => _GenReportPageState();
}

class _GenReportPageState extends State<GenReportPage> {
  int _selectedIndex = 3;
  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  late var selectedMeetingType = "Meeting";
  int influencerCount = 1000;
  int influencerMet = 650;
  int activeTeamMembers = 80;
  int inactiveTeamMembers = 20;
  int successfullMeetings = 650;

  /*void setMeetingType(String type){
  }*/

  // Method to handle bottom navigation item tap
  void _onNavItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InfluencersPage()),
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.person, color: Color.fromRGBO(5, 50, 70, 1.0)),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromRGBO(5, 50, 70, 1.0)),
            onPressed: () {
              print('Notifications tapped');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Generate",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(5, 50, 70, 1.0),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Report",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(5, 50, 70, 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Download PDF',
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
                            style: TextStyle(color: Colors.grey.shade600,fontSize: 16),
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
                            style: TextStyle(color: Colors.grey.shade600,fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Influencer",
                        style: TextStyle(
                          fontSize: 20,
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
                                      const Text(
                                        "Total",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        influencerCount.toString(), // Replace with your 'total' variable
                                        style: const TextStyle(
                                          fontSize: 25,
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
                                      const Text(
                                        "Met",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        influencerMet.toString(), // Replace with your 'met' variable
                                        style: const TextStyle(
                                          fontSize: 25,
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
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Team Member",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(5, 50, 70, 1.0),
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
                                      const Text(
                                        "Active",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        activeTeamMembers.toString(), // Replace with your 'total' variable
                                        style: const TextStyle(
                                          fontSize: 25,
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
                                      const Text(
                                        "Inactive",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        inactiveTeamMembers.toString(), // Replace with your 'met' variable
                                        style: const TextStyle(
                                          fontSize: 25,
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
                              selectedMeetingType = "Meeting";
                              setState((){});
                            },
                            child: Text(
                              "Meeting",
                              style: selectedMeetingType == "Meeting"
                                  ? const TextStyle(color: Color.fromRGBO(5, 50, 70, 1.0),fontWeight: FontWeight.w600, fontSize: 20,decoration: TextDecoration.underline)
                                  : TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 20),
                            )
                          ),
                          TextButton(
                            onPressed: () {
                              selectedMeetingType = "Baitak";
                              setState((){});
                            },
                            child: Text(
                              "Baitak",
                              style: selectedMeetingType == "Baitak"
                                  ? const TextStyle(color: Color.fromRGBO(5, 50, 70, 1.0),fontWeight: FontWeight.w600, fontSize: 20,decoration: TextDecoration.underline)
                                  : TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            //meeting data
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0), // Padding around the container
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(198, 198, 198, 1), // Background color
                    borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                    border: Border.all(
                      color: const Color.fromRGBO(198,198,198,1.0), // Border color
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
                  //meeting data
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                        children: [
                          //Successful meeting count
                          Column(
                            children: [
                              Text(
                                successfullMeetings.toString(),
                                style: const TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                "Successful",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                "Meeting",
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 40),
                          //Meeting data
                          Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 170,
                                    padding: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Background color
                                      borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                      border: Border.all(
                                        color: Colors.grey.shade400, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Meeting Name",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Date: DD/MM/YYYY",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Time: HH:MM",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Location: City, District",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Container(
                                    width:170,
                                    padding: const EdgeInsets.all(5.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Background color
                                      borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                      border: Border.all(
                                        color: Colors.grey.shade400, // Border color
                                        width: 1, // Border width
                                      ),
                                    ),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Meeting Name",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Date: xx/xx/xxxx",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Time: HH:MM",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Location: City, District",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'View all meetings',
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
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
                  label: "Add Influencer",
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
                  label: "Meeting",
                  iconPath: 'assets/icon/meeting.png',
                  isActive: _selectedIndex == 2,
                  onPressed: () => _onNavItemTapped(2),
                ),
                _buildBottomNavItem(
                  label: "Report",
                  iconPath: 'assets/icon/report.png',
                  isActive: _selectedIndex == 3,
                  onPressed: () => _onNavItemTapped(3),
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
