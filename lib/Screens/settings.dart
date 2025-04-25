import 'dart:convert';
import 'package:flutter/material.dart';
import '../Service/api_service.dart';
import 'login.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;
    double largeFontSize = normFontSize + 4;
    double smallFontSize = normFontSize - 2;
    double squareSize = MediaQuery.of(context).size.width * 0.4;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(60, 245, 200, 1.0),
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          // Profile Section
          Center(
            child: Container(
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
          ),
          SizedBox(height: 30),
          // Username Section
          Text(
            'Username: ${apiService.first_name} ${apiService.last_name}',
            style: TextStyle(fontSize: largeFontSize, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Designation: ${apiService.designation}', style: TextStyle(fontSize: normFontSize)),
          SizedBox(height: 8),
          Text('District: ${apiService.district}', style: TextStyle(fontSize: normFontSize)),
          SizedBox(height: 8),
          Text('State: ${apiService.state}', style: TextStyle(fontSize: normFontSize)),
          Divider(),

          // Logout Section
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Logout',style: TextStyle(color: Colors.red),),
                  content: Text('Do you want to logout?'),
                  actions: <Widget>[
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
                            content: Container(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 5),
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
            child: Text('Log Out', style: TextStyle(fontSize: largeFontSize,color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
