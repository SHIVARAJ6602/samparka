import 'package:flutter/material.dart';

import '../Screens/profile_page.dart';
import '../Screens/login.dart';
import '../Screens/manage_influnecer.dart';
import '../Screens/manage_karyakartha.dart';
import '../Service/api_service.dart';

class MenuDrawer extends StatelessWidget {
  final ApiService apiService;
  final double normFontSize;

  const MenuDrawer({
    Key? key,
    required this.apiService,
    this.normFontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(60, 245, 200, 1.0),
                  ),
                  child: Column(
                    children: [
                      Expanded(child: SizedBox()),
                      SizedBox(
                        width: 200,
                        height: 100,
                        child: Image.asset(
                          'assets/logo/samparka.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.person,
                  label: 'Profile',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  ),
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.group,
                  label: 'Manage Influencers',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageInfluencerPage()),
                  ),
                ),
                _buildDrawerButton(
                  context,
                  icon: Icons.groups,
                  label: 'Manage Karyakartha',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageKaryakarthaPage()),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: normFontSize,
                      color: Colors.red,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: Text('Logout'),
                        content: Text('Do you want to logout?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => AlertDialog(
                                  title: Text('Logging out...'),
                                  content: Center(
                                    child: CircularProgressIndicator(strokeWidth: 5),
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
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0, top: 8),
                child: Center(
                  child: Text(
                    'Built with ❤️\nby local hands',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
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

  Widget _buildDrawerButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onPressed,
      }) {
    return ListTile(
      title: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.teal),
        label: Text(
          label,
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
    );
  }
}
