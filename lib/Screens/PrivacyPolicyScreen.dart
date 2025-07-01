import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Service/api_service.dart';
import 'login.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  PrivacyPolicyScreen({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  static const _policyUrl = 'https://www.privacypolicies.com/live/2cd1ab57-7e78-4a12-962c-f20bc8775fef';
  final apiService = ApiService();

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse(_policyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $_policyUrl';
    }
  }

  void _confirmDecline(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy Required'),
        content: const Text(
          'You must accept the privacy policy to use this app. Would you like to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDecline();
              Future.delayed(const Duration(milliseconds: 300), () {
                SystemNavigator.pop();
              });
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(60, 245, 200, 1.0),
              Color.fromRGBO(2, 40, 60, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Card(
                color: Colors.white, // White background for the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/logo/logo.png',
                          height: 150,
                        ),
                      ),
                      const Text(
                        'Privacy Policy Agreement',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'We value your privacy. Please review our privacy policy to understand how your data is collected, used, and protected.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      (!apiService.privacyPolicyAgreed)? const SizedBox(height: 16): const SizedBox(height: 8),
                      if (!apiService.privacyPolicyAgreed)
                      const Text(
                        'By accepting, you agree to our privacy policy and terms of use.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Read the full policy here:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _launchPrivacyPolicy,
                        child: const Text(
                          'Click here to read our privacy policy',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      //Show deletion message only when Privacy policy is accepted
                      if (apiService.privacyPolicyAgreed)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Account Deletion:\n\nIf you wish to delete your account, please contact your local administrator or email us at samparkamysuru@gmail.com.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      //Show Accept and decline only when not accepted.
                      if(!apiService.privacyPolicyAgreed)
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color.fromRGBO(182, 20, 20, 1.0),
                                  Color.fromRGBO(253, 5, 5, 1.0),
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () => _confirmDecline(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ), // Make sure the background is transparent
                              ),
                              child: const Text('Decline', style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color.fromRGBO(7, 82, 122, 1.0),
                                  Color.fromRGBO(60, 170, 145, 1.0),
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                onAccept();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                      (Route<dynamic> route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ), // Make sure the background is transparent
                              ),
                              child: const Text('Accept', style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
