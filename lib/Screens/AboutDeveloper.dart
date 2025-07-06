import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;
    double largeFontSize = normFontSize + 4;
    double profileSize = MediaQuery.of(context).size.width * 0.4;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(60, 245, 200, 1.0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'About Developer',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image
            Container(
              width: profileSize,
              height: profileSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(2, 40, 60, 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    'https://github.com/SHIVARAJ6602.png', // <-- Your profile pic here
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Name & Role
            Text(
              'Shivaraj S',
              style: TextStyle(fontSize: largeFontSize, fontWeight: FontWeight.bold),
            ),
            Text(
              'MCA (Masters in Computer Applications)',
              style: TextStyle(fontSize: normFontSize, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Text(
              'Flutter Developer & Backend Engineer',
              style: TextStyle(fontSize: normFontSize, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // Bio/About
            Text(
              'I am a passionate developer and the sole creator of the Samparka App. I specialize in building scalable mobile and backend systems, with a strong focus on design, performance, and simplicity.',
              style: TextStyle(fontSize: normFontSize, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Tech Stack
            _sectionTitle('Technologies Used'),
            _techItem('• Flutter (Frontend)'),
            _techItem('• Django (Backend)'),
            _techItem('• MySQL, S3, REST APIs'),

            const SizedBox(height: 30),

            // Contact Section
            _sectionTitle('Contact'),
            _infoRow(context, Icons.email, 'shivaraj6602@gmail.com', normFontSize),
            _infoRow(context, Icons.link, 'linkedin.com/in/shivaraj6602', normFontSize),
            _infoRow(context, Icons.link, 'github.com/SHIVARAJ6602', normFontSize),
            _infoRow(context, Icons.location_on, 'Mysuru, India', normFontSize),

          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _techItem(String tech) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(tech, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
      ),
    );
  }

  void _handleTap(BuildContext context, String value) async {
    final Uri uri;

    if (value.contains('@')) {
      uri = Uri(scheme: 'mailto', path: value);
    } else if (value.startsWith('http') || value.startsWith('www.') || value.startsWith('github') || value.startsWith('linkedin')) {
      uri = Uri.parse(value.startsWith('http') ? value : 'https://$value');
    } else {
      uri = Uri.parse('https://www.google.com/maps/search/${Uri.encodeComponent(value)}');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: $value')),
      );
    }
  }



  Widget _infoRow(BuildContext context, IconData icon, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          _handleTap(context, value);
        },
        child: Row(
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: fontSize, color: Colors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
