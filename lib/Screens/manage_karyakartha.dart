import 'package:flutter/material.dart';
import 'package:samparka/Screens/register_user.dart';
import 'package:samparka/Screens/upload_kr_excel.dart';

import '../Service/api_service.dart';
import 'error_page.dart';
import 'migrate_karyakartha.dart';

class ManageKaryakarthaPage extends StatelessWidget {
  ManageKaryakarthaPage({super.key});

  final apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Karyakartha'),
        backgroundColor: Color.fromRGBO(60, 245, 200, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildButton(context, 'Add Karyakartha', Icons.person_add),
            _buildButton(context, 'Migrate Karyakartha', Icons.compare_arrows),
            _buildButton(context, 'Upload Excel', Icons.upload_file),
            //_buildButton(context, 'Transfer', Icons.swap_horiz),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(60, 245, 200, 1.0),
          foregroundColor: Colors.black87,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: Size(double.infinity, 48),
        ),
        onPressed: () {
          // TODO: Implement functionality
          switch (label) {
            case "Add Karyakartha":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterUserPage()),
              );
              break;
            case "Migrate Karyakartha":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MigrateUserPage(userId: apiService.UserId, lvl: apiService.lvl,)),
              );
              break;
              case "Upload Excel":
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadKRExcel()),
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
