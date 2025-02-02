import 'dart:convert';

import 'package:flutter/material.dart';

import '../Service/api_service.dart';

class InfluencerProfilePage extends StatefulWidget {
  @override
  _InfluencerProfilePageState createState() => _InfluencerProfilePageState();
}

class _InfluencerProfilePageState extends State<InfluencerProfilePage> {

  final apiService = ApiService();

  List<dynamic> influencers = [];
  late List<dynamic> result;

  late final String name = 'name';
  late final String designation = 'designation';
  late final String description = 'description';
  late final String hashtags = 'hastags';
  late final String profileImage = '';

  Future<bool> fetchInfluencers() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.homePage();
      setState(() {
        // Update the influencers list with the fetched data
        influencers = result;
      });
      return true;
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar background transparent
        elevation: 0, // Remove the app bar shadow
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
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: MediaQuery.of(context).size.width * 0.08,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: profileImage.isNotEmpty ? MemoryImage(base64Decode(profileImage.split(',')[1])) : null, // Use NetworkImage here
                                  child: profileImage.isEmpty
                                      ? Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: MediaQuery.of(context).size.width * 0.14,
                                  )
                                      : null,
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                            // Influencer Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name, // Dynamic name
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(5, 50, 70, 1.0),
                                    ),
                                  ),
                                  Text(
                                    designation, // Dynamic designation
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(5, 50, 70, 1.0),
                                    ),
                                  ),
                                  Text(
                                    description, // Dynamic designation
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromRGBO(5, 50, 70, 1.0),
                                    ),
                                  ),
                                  Text(
                                    hashtags, // Dynamic designation
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                ],
                              ),
                            ),
                            //change request
                            Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width*0.25,
                                  height: MediaQuery.of(context).size.width*0.25*0.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color.fromRGBO(133, 1, 1, 1.0),
                                        Color.fromRGBO(237, 62, 62, 1.0),
                                      ],
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Change\nRequest ',
                                            style: TextStyle(
                                              fontSize: smallFontSize-3,
                                              color: Colors.white,
                                              //fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 1),  // Add space between the text and the image
                                          Transform.rotate(
                                            angle: 5.7,  // Adjust the rotation angle here as needed
                                            child: Icon(
                                              Icons.arrow_forward,  // You might want to use arrow_forward or another arrow icon
                                              color: Colors.white,
                                              size: largeFontSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
              ),
            ],
          )
        ],
      ),
    );
  }
}