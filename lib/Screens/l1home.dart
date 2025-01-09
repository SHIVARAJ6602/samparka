import 'package:flutter/material.dart';
import 'add_influencer.dart';
import 'gen_report.dart';
import 'login.dart';
import 'API_TEST.dart'; //TaskListScreen()
import 'package:samparka/Service/api_service.dart';

class InfluencersPage extends StatefulWidget {
  const InfluencersPage({super.key});

  @override
  _InfluencersPageState createState() => _InfluencersPageState();
}

class _InfluencersPageState extends State<InfluencersPage> {
  // This keeps track of the selected index for the bottom navigation
  int _selectedIndex = 0;
  final ApiService apiService = ApiService();

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
  late String currentUrl;
  @override
  void initState() {
    super.initState();
    //handleButtonPress();
    username = apiService.userName;
    isAuthenticated = apiService.isAuthenticated;
    token = apiService.token;
    currentUrl = apiService.baseUrl;
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
  /******************************************************/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar background transparent
        elevation: 0, // Remove the app bar shadow
        title: Text(apiService.userName),
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
            ListTile(
              title: Text('Username: $username'),
            ),
            ListTile(
              title: Text('Is Authenticated: $isAuthenticated'),
            ),
            ListTile(
              title: Text('Token: ${token.length > 20 ? token.substring(0, 20) : token}..'),
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
                                content: CircularProgressIndicator(),
                              ),
                            );

                            await apiService.logout();

                            Navigator.pop(context);
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
                      const SizedBox(height: 22),
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
                            SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true, // Ensures ListView only takes as much space as needed
                                padding: EdgeInsets.zero,  // Remove default padding
                                itemCount: 2,
                                itemBuilder: (context, index) {
                                  return const Padding(
                                    padding: EdgeInsets.only(left: 16,right: 16,top: 20),
                                    child: InfluencerCard(),
                                  );
                                },
                              ),
                            ),
                            // View All Influencers Button
                            TextButton(
                              onPressed: () {},
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
                _buildBottomNavItem(
                  label: "API",
                  iconPath: 'assets/icon/report.png',  // Use the PNG file path
                  isActive: _selectedIndex == 4,
                  onPressed: () => _onNavItemTapped(4),
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
  const InfluencerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: const Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
          ),
          SizedBox(width: 16),
          // Influencer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(5, 50, 70, 1.0),
                  ),
                ),
                Text(
                  'Designation',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(5, 50, 70, 1.0),
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(5, 50, 70, 1.0),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1),
                Text(
                  '#hashtags  #hashtags',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
