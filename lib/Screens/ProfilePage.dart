import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemUiOverlayStyle
import 'package:samparka/Screens/update_user_profile.dart';
import '../Service/api_service.dart';
import 'AboutDeveloper.dart';
import 'PrivacyPolicyScreen.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final apiService = ApiService();
  final TextEditingController newUrlController = TextEditingController();

  late String username;
  late bool isAuthenticated;
  late String token;
  late int level;
  late String currentUrl;
  String? selectedRadio = 'url1';

  @override
  void initState() {
    super.initState();
    username = apiService.first_name;
    isAuthenticated = apiService.isAuthenticated;
    token = apiService.token;
    level = apiService.lvl;
    currentUrl = apiService.baseUrl;

    // Optional: Set status bar icons to dark
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void handleButtonPress() {
    setState(() {
      if (newUrlController.text.isNotEmpty) {
        currentUrl = newUrlController.text;
      } else {
        currentUrl = selectedRadio == 'url1'
            ? apiService.baseUrl1
            : apiService.baseUrl2;
      }
      apiService.baseUrl = currentUrl;
      apiService.saveData();
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('URL Changed!'),
        content: Text('Current URL: $currentUrl'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Logout', style: TextStyle(color: Colors.red)),
        content: Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Logging out...'),
                  content: SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 5)),
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
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;
    double largeFontSize = normFontSize + 4;
    double squareSize = MediaQuery.of(context).size.width * 0.4;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        backgroundColor: const Color.fromRGBO(60, 245, 200, 1.0),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateUserPage(apiService.UserId),
                ),
              );
            },
            tooltip: 'Edit',
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8)],
              ),
              child: Column(
                children: [
                  //Profile Image
                  Center(
                    child: Container(
                      width: squareSize,
                      height: squareSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(85),
                        border: Border.all(color: Colors.grey.shade400),
                        color: Colors.grey[200],
                        boxShadow: [
                          if(apiService.profileImage != '')
                            BoxShadow(
                              color: Color.fromRGBO(5, 50, 70, 1.0).withOpacity(0.5), // Grey shadow color with opacity
                              spreadRadius: 1, // Spread radius of the shadow
                              blurRadius: 3, // Blur radius of the shadow
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
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${apiService.first_name} ${apiService.last_name}',
                    style: TextStyle(fontSize: largeFontSize, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.phone, 'Phone Number', apiService.phone, normFontSize),
                  _infoRow(Icons.badge, 'Designation', apiService.designation, normFontSize),
                  _infoRow(Icons.location_city, 'District', apiService.district, normFontSize),
                  _infoRow(Icons.map, 'State', apiService.state, normFontSize),
                ],
              ),
            ),

            if(apiService.devVersion && apiService.phone == '7337620623')
            const SizedBox(height: 40),

            // URL switcher (Optional)
            if(apiService.devVersion && apiService.phone == '7337620623')
              Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Change API URL", style: TextStyle(fontSize: largeFontSize, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: newUrlController,
                    decoration: InputDecoration(hintText: 'Current: ${apiService.baseUrl.substring(0, 20)} (edit)'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Main Server'),
                          value: 'url1',
                          groupValue: selectedRadio,
                          onChanged: (value) {
                            setState(() {
                              selectedRadio = value;
                              newUrlController.clear();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Test Server'),
                          value: 'url2',
                          groupValue: selectedRadio,
                          onChanged: (value) {
                            setState(() {
                              selectedRadio = value;
                              newUrlController.clear();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: handleButtonPress,
                    child: Text('Apply URL Change'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            // Privacy Policy Button
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyScreen(onAccept: () {  }, onDecline: () {  },)),
                );
              },
              icon: Icon(Icons.privacy_tip, color: Colors.teal),
              label: Text(
                'Privacy Policy And Account Deletion',
                style: TextStyle(fontSize: normFontSize, color: Colors.teal),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.teal),
              ),
            ),
            const SizedBox(height: 20),


            // Logout Button
            ElevatedButton.icon(
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text('Log Out', style: TextStyle(fontSize: largeFontSize, color: Colors.red)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _confirmLogout,
            ),

            const SizedBox(height: 20),

            TextButton.icon(
              icon: Icon(Icons.info_outline, color: Colors.grey[700]),
              label: Text(
                'About Developer',
                style: TextStyle(
                  fontSize: normFontSize,
                  color: Colors.grey[700],
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutDeveloperPage()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 10),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize)),
          Expanded(child: Text(value, style: TextStyle(fontSize: fontSize))),
        ],
      ),
    );
  }
}
