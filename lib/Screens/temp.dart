import 'package:flutter/material.dart';

class TempPage extends StatefulWidget {
  @override
  _HamburgerMenuPageState createState() => _HamburgerMenuPageState();
}

class _HamburgerMenuPageState extends State<TempPage> {
  // Text editing controllers for text fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController newUrlController = TextEditingController();

  // State variables for radio buttons
  String? selectedRadio = 'url1';
  String currentUrl = 'https://api.example.com';  // Default URL

  // Sample user data (can be fetched from an API service)
  String username = 'JohnDoe';
  bool isAuthenticated = true;
  String token = 'abc123token';

  // Function to handle button press logic
  void handleButtonPress() {
    setState(() {
      // For demonstration, update the URL based on the radio button selected
      currentUrl = selectedRadio == 'url1' ? 'https://api.example1.com' : 'https://api.example2.com';
    });

    // Logic for what should happen on button press
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Action Performed'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Hamburger Menu Example'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
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
              title: Text('Token: $token'),
            ),
            ListTile(
              title: Text('API URL: $currentUrl'),
            ),
            Divider(),
            // Submenu with radio buttons
            ExpansionTile(
              title: Text('Select API URL'),
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
                      Text('https://api.example1.com'),
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
                      Text('https://api.example2.com'),
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
              ],
            ),
            Divider(),
            // Text fields for user input (with labels)
            ListTile(
              title: TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
            ),
            ListTile(
              title: TextField(
                controller: tokenController,
                decoration: InputDecoration(labelText: 'Token'),
              ),
            ),
            ListTile(
              title: TextField(
                controller: urlController,
                decoration: InputDecoration(labelText: 'API URL'),
              ),
            ),
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
            Divider(),
            // Perform action button
            ListTile(
              title: ElevatedButton(
                onPressed: handleButtonPress,
                child: Text('Perform Action'),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Main Content Here'),
      ),
    );
  }
}

// Dummy LoginPage for navigation (just for example purposes)
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(child: Text('Login Page')),
    );
  }
}

