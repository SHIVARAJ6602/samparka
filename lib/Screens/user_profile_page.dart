import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:samparka/Screens/schedule_interaction.dart';
import 'package:samparka/Screens/view_influencers.dart';
import 'package:samparka/Screens/view_interaction.dart';

import '../Service/api_service.dart';

class UserProfilePage extends StatefulWidget {

  final String id;

  // Receiving the id directly through the constructor
  const UserProfilePage(this.id, {super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  final apiService = ApiService();

  List<dynamic> meetings = [{"id":"MT00001","title":"meet1","description":"adadad"},{"id":"MT00002","title":"meet2","description":"adadad"}];
  late List<dynamic> resultKR;
  late List<dynamic> resultGV;
  late List<dynamic> result;
  List<dynamic> tasks = [];
  List<dynamic> interactions = [];

  late String name = '';
  late String designation = '';
  late String description = '';
  late String hashtags = 'hastags';
  late String profileImage = '';
  late String KR_id = '';

  List<dynamic> influencers = [];

  TextEditingController titleController = TextEditingController();

  late bool loading = true;

  Future<void> fetchInfluencers() async {
    try {
      // Call the apiService.homePage() and store the result
      resultGV = await apiService.getInfluencer(0, 100,widget.id);
      print('Influencers User Screen $result');
      setState(() {
        resultGV.forEach((inf) {
          if (inf['soochi'] == 'AkhilaBharthiya') {
            inf['soochi'] = 'AB';
          } else if (inf['soochi'] == 'PranthyaSampark') {
            inf['soochi'] = 'PS';
          } else if (inf['soochi'] == 'JillaSampark') {
            inf['soochi'] = 'JS';
          }
          if (inf['interaction_level'] == 'Sampark') {
            inf['interaction_level'] = 'S1';
          } else if (inf['interaction_level'] == 'Sahavas') {
            inf['interaction_level'] = 'S2';
          } else if (inf['interaction_level'] == 'Samarthan') {
            inf['interaction_level'] = 'S3';
          } else if (inf['interaction_level'] == 'Sahabhag') {
            inf['interaction_level'] = 'S4';
          }
        });
        // Update the influencers list with the fetched data
        influencers = resultGV;
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    fetchInfluencers();
    setState(() {loading = true;});
    KR_id = widget.id;
    print(KR_id[0][0]);
    getKaryakartha();
    fetchTasks(KR_id);
    setState(() {});
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        loading = false; // Set loading to false after 2 seconds
      });
    });
  }

  Future<bool> getKaryakartha() async{
    try {
      // Call the apiService.homePage() and store the result
      resultKR = await apiService.getKaryakartha(KR_id);
      setState(() {
        // Update the influencers list with the fetched data
        //meetings = result;
        print(resultKR[0]['first_name']);
        print("getKR KR data: $resultKR");
        print(resultKR[0]['profile_image']);
        name = '${resultKR[0]['first_name']} ${resultKR[0]['last_name']}';
        designation = resultKR[0]['designation'];
        description = resultKR[0]['description']??'';
        profileImage = resultKR[0]['profile_image'];
        print('Image: ${resultKR[0]['profile_image']}');
        setState(() {});

      });
      return true;
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
    return false;
  }

  Future<void> fetchTasks(GV_id) async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getTasks(GV_id);
      setState(() {
        // Update the influencers list with the fetched data
        tasks = result;
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching interactions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String GV_id = widget.id;
    print(GV_id);
    print(widget.id);
    print("profile image: $profileImage");
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
                      //inf details
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: (MediaQuery.of(context).size.width * 0.80) / 3,  // 90% of screen width divided by 3 images
                                height: (MediaQuery.of(context).size.width * 0.80) / 3,  // Fixed height for each image
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(color: Colors.grey.shade400),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5), // Grey shadow color with opacity
                                      spreadRadius: 2, // Spread radius of the shadow
                                      blurRadius: 7, // Blur radius of the shadow
                                      offset: Offset(0, 4), // Shadow position (x, y)
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: (profileImage.isNotEmpty)
                                      ? Image.network(
                                    profileImage,  // Ensure the URL is encoded
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
                                        color: Colors.red,  // Placeholder color for invalid image URLs
                                        child: Center(
                                          child: Icon(Icons.error, color: Colors.white),  // Display error icon
                                        ),
                                      );
                                    },
                                  )
                                      : Container(
                                    color: Colors.grey[200],  // Default background color if no image
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 50),
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
                                Row(
                                  children: [
                                    Text(
                                      designation, // Dynamic designation
                                      style: TextStyle(
                                        fontSize: smallFontSize,
                                        color: Color.fromRGBO(5, 50, 70, 1.0),
                                      ),
                                    ),
                                    Container(
                                      width: 2, // Divider width
                                      height: smallFontSize, // Divider height (you can adjust this as needed)
                                      color: Colors.black, // Divider color
                                      margin: EdgeInsets.symmetric(horizontal: 8), // Add spacing around the divider
                                    ),
                                    Text(
                                      'Shreni', // Dynamic designation
                                      style: TextStyle(
                                        fontSize: smallFontSize,
                                        color: Color.fromRGBO(5, 50, 70, 1.0),
                                      ),
                                    ),
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30,),
                      // Recently Assigned Influencers Title
                      Text('Assigned Influencers',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.041 *2,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(5, 50, 70, 1.0),
                        ),
                      ),
                      const SizedBox(height: 1),
                      // Influencer Cards
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromRGBO(60, 170, 145, 1.0),
                              Color.fromRGBO(2, 40, 60, 1),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            // If the list is empty, show a message
                            if (loading)
                              Center(
                                child: CupertinoActivityIndicator(
                                  color: Colors.white,
                                  radius: 20, // Customize the radius of the activity indicator
                                ),
                              )
                            else
                              if (influencers.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No Influencer Assigned',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.041+2,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: List.generate(
                                    (influencers.length < 4) ? influencers.length : 3, // Display either all members or just 3
                                        (index) {
                                      final influencer = influencers[index]; // Access the member data
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                        child: InfluencerCard(
                                          id: influencer['id']!,
                                          name: influencer['fname']??'',
                                          designation: influencer['designation']!,
                                          description: influencer['description']??'',
                                          hashtags: influencer['hashtags']??'',
                                          soochi: influencer['soochi']??'',
                                          itrLvl: influencer['interaction_level']??'',
                                          profileImage: influencer['profile_image'] != null && influencer['profile_image']!.isNotEmpty
                                              ? apiService.baseUrl.substring(0,40)+influencer['profile_image']!
                                              : '',
                                        ),
                                      );
                                    },
                                  ),
                                ),

                            if (influencers.isNotEmpty)
                            // View All Influencers Button
                              TextButton(
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ViewInfluencersPage(KR_id)),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'View all Influencers',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.041+2,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Image.asset(
                                      'assets/icon/arrow.png',
                                      color: Colors.white,
                                      width: 12,
                                      height: 12,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      /*
                      SizedBox(height: 16),
                      Text(description,style: TextStyle(fontSize: normFontSize)),
                      SizedBox(height: 16),
                      //new meeting button
                      Row(
                        children: [
                          Text('Recent Meeting',style: TextStyle(color: Color.fromRGBO(2, 40, 60, 1),fontSize: largeFontSize+8,fontWeight: FontWeight.bold),),
                          Expanded(child: SizedBox()),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 0,horizontal: 4),
                            //width: MediaQuery.of(context).size.width*0.25,
                            //height: largeFontSize+6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Color.fromRGBO(2, 40, 60, 1),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddInteractionPage(GV_id)),
                                );
                              },
                              style: TextButton.styleFrom(
                                //padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '+ Add Meeting',
                                      style: TextStyle(
                                        fontSize: smallFontSize,
                                        color: Colors.white,
                                        //fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // meetings Cards
                      Container(
                        child: Column(
                          children: [
                            // If the list is empty, show a message
                            if (loading)
                              Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.blue,
                                ),
                              )
                            else
                              if (meetings.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No Meetings Available',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(2, 40, 60, 1),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: meetings.length, // The number of items in your data list
                                  itemBuilder: (context, index) {
                                    final meeting = meetings[index]; // Access the influencer data for each item
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
                                      child: meetingCard(
                                        title: meeting['title']!,
                                        description: meeting['description']!,
                                        id: meeting['id']!,
                                      ),
                                    );
                                  },
                                ),

                            if (meetings.isNotEmpty)
                            // View All Influencers Button
                              TextButton(
                                onPressed: () async {
                                  /*Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => UserProfilePage('GV00000001')),
                                  );*/
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'View all Meetings',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Image.asset(
                                      'assets/icon/arrow.png',
                                      color: Colors.grey[800],
                                      width: 12,
                                      height: 12,
                                    ),
                                  ],
                                ),
                              ),

                          ],
                        ),
                      ),*/
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 20, // Customize the radius of the activity indicator
                      ),
                      const SizedBox(height: 10), // Space between the indicator and text
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class meetingCard extends StatelessWidget {
  final String title;
  final String description;
  final String id;

  const meetingCard({
    super.key,
    required this.title,
    required this.description,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2;
    return Container(
      //padding: const EdgeInsets.all(0), // Container padding
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // Bottom border color
            width: 1, // Bottom border width
          ),
        ),
      ),

      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ViewInteractionPage(id)),
          );
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 0,right: 0,bottom: 4,top: 0), // Add padding to the content
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align all children to the start
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.6, // 50% width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0), // Space between text
                      child: Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: largeFontSize),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        description,
                        style: TextStyle(fontSize: smallFontSize),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: SizedBox()), // Fills the remaining space
              //arrow
              Center(
                child: Column(
                  children: [
                    Transform.rotate(
                      angle: 4.7124,  // Rotate the arrow 90 degrees
                      child: Image.asset(
                        'assets/icon/arrow.png',
                        color: Colors.grey,
                        width: 15,  // Adjust the size of the image
                        height: 15, // Adjust the size of the image
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}