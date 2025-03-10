import 'dart:convert';

import 'package:flutter/material.dart';

import '../Service/api_service.dart';
import 'influencer_profile.dart';

class ViewInfluencersPage extends StatefulWidget {
  const ViewInfluencersPage({super.key});

  @override
  _ViewInfluencersPageState createState() => _ViewInfluencersPageState();
}

class _ViewInfluencersPageState extends State<ViewInfluencersPage> {
  final apiService = ApiService();

  List<dynamic> influencers = [];
  late List<dynamic> result;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchInfluencers();
    loading = false;
  }

  // Define a function to fetch data
  Future<void> fetchInfluencers() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.myInfluencer(0, 100);
      print(result);
      setState(() {
        result.forEach((inf) {
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
        influencers = result;
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      appBar: AppBar(
        title: Text('Influencers'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: influencers.length,
        itemBuilder: (context, index) {
          final influencer = influencers[index];
          print('name: ${influencer['fname']}');
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: InfluencerCard(
              id: influencer['id']!,
              name: '${influencer['fname'] ?? ''} ${influencer['lname'] ?? '.'}'??'',
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
    );
  }
}

class InfluencerList extends StatelessWidget {
  InfluencerList({super.key});

  // Sample data
  final List<Map<String, String>> influencerData = [
    {
      'id': 'GV00000002',
      'fname': 'Ravi',
      'designation': 'Leader',
      'description': 'Some description',
      'hashtags': '#tag1 #tag2',
    },
    {
      'id': 'GV00000003',
      'fname': 'Sara',
      'designation': 'Manager',
      'description': 'Another description',
      'hashtags': '#tag3 #tag4',
    },
    // Add more data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: influencerData.length,
      itemBuilder: (context, index) {
        final influencer = influencerData[index];
        print('name: ${influencer['fname']}');
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: InfluencerCard(
            id: influencer['id']!,
            name: influencer['fname']!,
            designation: influencer['designation']!,
            description: influencer['description']!,
            hashtags: influencer['hashtags']!,
            soochi: influencer['soochi']??'',
            itrLvl: influencer['interaction_level']??'',
            profileImage: influencer['profile_image'] != null && influencer['profile_image']!.isNotEmpty
                ?influencer['profile_image']!
                : '',
          ),
        );
      },
    );
  }
}


class InfluencerCard extends StatelessWidget {
  final String id;
  final String name;
  final String designation;
  final String description;
  final String hashtags;
  final String soochi;
  final String itrLvl;
  final String profileImage;

  const InfluencerCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags,
    required this.profileImage,
    required this.id,
    required this.soochi,
    required this.itrLvl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(0), // Container padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfluencerProfilePage(id)),
              );
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              )),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 0,right: 0,bottom: 8,top: 8), // Add padding to the content
              child: Row(
                children: [
                  // Profile Picture (placeholder)
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
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 20,
          child: Container(
            width: 22,  // Diameter of the circle
            height: 22,
            decoration: BoxDecoration(
              color: Color.fromRGBO(59, 171, 144, 1.0),  // Blue background color
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(198, 198, 198, 1.0), // Border color
                width: 0.8, // Border width
              ),
            ),

            child: Center(
              child: Text(
                soochi,  // The letter inside the circle
                style: TextStyle(
                  fontSize: 11,  // Font size for "L"
                  color: Colors.white,  // White color for the letter
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 38,
          child: Container(
            width: 22,  // Diameter of the circle
            height: 22,
            decoration: BoxDecoration(
              color: Colors.blue,  // Blue background color
              shape: BoxShape.circle,  // Make it a circle
              border: Border.all(
                color: const Color.fromRGBO(198, 198, 198, 1.0), // Border color
                width: 0.8, // Border width
              ),
            ),
            child: Center(
              child: Text(
                itrLvl,  // The letter inside the circle
                style: TextStyle(
                  fontSize: 11,  // Font size for "L"
                  color: Colors.white,  // White color for the letter
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
