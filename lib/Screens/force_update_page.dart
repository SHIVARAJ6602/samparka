import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Service/api_service.dart';

class ForceUpdatePage extends StatefulWidget {
  final Widget nextPage;

  const ForceUpdatePage({super.key, required this.nextPage});

  @override
  State<ForceUpdatePage> createState() => _ForceUpdatePageState();
}

class _ForceUpdatePageState extends State<ForceUpdatePage> {
  final apiService = ApiService();
  bool _checkingVersion = true;
  NewVersionPlus? _newVersion;
  VersionStatus? _versionStatus;

  @override
  void initState() {
    super.initState();
    //spoofUser();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    _newVersion = NewVersionPlus(
      androidId: "com.samparkamysuru.samparka", // Your app's Android ID
      iOSId: "000000000", // Your iOS App Store ID
    );

    _versionStatus = await _newVersion!.getVersionStatus();

    if (_versionStatus == null || !_versionStatus!.canUpdate) {
      // No update needed, proceed to your app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.nextPage),
      );
    } else {
      // Update needed, stay here and show update UI
      setState(() {
        _checkingVersion = false;
      });
    }
  }

  void _launchStore() async {
    final url = _versionStatus?.appStoreLink ?? '';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the app store.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingVersion) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo/samparka.png', height: 100),
              const SizedBox(height: 30),
              const CupertinoActivityIndicator(
                color: Colors.green,
                radius: 20, // Customize the radius of the activity indicator
              )
            ],
          ),
        ),
      );
    }

    // Update required UI
    // Update required UI
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo/logo.png', height: 150),
              const SizedBox(height: 40),
              Text(
                "Update Required",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                "A new version (${_versionStatus?.storeVersion}) of Samparka is available. Please update the app to continue.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
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
                  onPressed: _launchStore,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 0,right: 0, bottom: 10,top: 10), // Remove padding to fill the entire container
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                  ),
                  child: Center(
                    child: Text(
                      "Update Now",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.041+7,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => widget.nextPage),
                  );
                },
                child: const Text(
                  "I'll update later",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
