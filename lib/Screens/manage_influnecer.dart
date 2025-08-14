import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samparka/Screens/migrate_influencer.dart';
import 'package:samparka/Screens/upload_gv_excel.dart';
import 'package:samparka/Service/api_service.dart';

import 'add_influencer.dart';
import 'error_page.dart';

class ManageInfluencerPage extends StatelessWidget {
  ManageInfluencerPage({super.key});

  final apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Manage Influencer',
          style: TextStyle(color: Color.fromRGBO(5, 50, 70, 1.0)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: Color.fromRGBO(5, 50, 70, 1.0)), // For back button color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildButton(context, 'Add Influencer', Icons.person_add),
            _buildButton(context, 'Migrate Influencer', Icons.compare_arrows),
            _buildButton(context, 'Upload Excel', Icons.upload_file),
            //_buildButton(context, 'Transfer', Icons.swap_horiz),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, IconData icon,) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white), // Ensure icon color contrasts with button
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(2, 40, 60, 1),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: Size(double.infinity, 48),
          shape: RoundedRectangleBorder( // Optional: if you want rounded corners like in some parts of user_profile_page
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          switch (label) {
            case "Add Influencer":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddInfluencerPage()),
              );
              break;
            case "Migrate Influencer":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MigrateInfluencerPage(apiService.UserId)),
              );
              break;
            case "Upload Excel":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadGVExcel()),
              );
              break;
            default:
                // Handle other cases if needed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ErrorPage()),
              );
              break;
          }
        },
      ),
    );
  }
}
