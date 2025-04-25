import 'dart:convert';

import 'package:flutter/material.dart';

import '../Service/api_service.dart';
import 'influencer_profile.dart';

class ViewInfluencersPage extends StatefulWidget {
  final String id;

  const ViewInfluencersPage(this.id,{super.key});

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
      result = await apiService.getInfluencer(0, 100,widget.id);
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
              //hashtags: influencer['hashtags']??'',
              hashtags: '',
              soochi: influencer['soochi']??'',
              itrLvl: influencer['interaction_level']??'',
              profileImage: influencer['profile_image'] != null && influencer['profile_image']!.isNotEmpty
                  ? influencer['profile_image']!
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
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
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
                  // Profile Picture
                  Container(
                    width: (MediaQuery.of(context).size.width * 0.80) / 5,  // 90% of screen width divided by 3 images
                    height: (MediaQuery.of(context).size.width * 0.80) / 5,  // Fixed height for each image
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.grey.shade400),
                      color: Colors.grey[200],
                      boxShadow: [
                        if(profileImage.isNotEmpty)
                          BoxShadow(
                            color: Color.fromRGBO(5, 50, 70, 1.0).withOpacity(0.5), // Grey shadow color with opacity
                            spreadRadius: 1, // Spread radius of the shadow
                            blurRadius: 7, // Blur radius of the shadow
                            offset: Offset(0, 4), // Shadow position (x, y)
                          ),
                        if(profileImage.isEmpty)
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Grey shadow color with opacity
                            spreadRadius: 1, // Spread radius of the shadow
                            blurRadius: 3, // Blur radius of the shadow
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
                            color: Colors.grey[200],  // Placeholder color for invalid image URLs
                            child: Center(
                              child: Icon(Icons.error, color: Colors.grey[400]),  // Display error icon
                            ),
                          );
                        },
                      )
                          : Icon(
                        Icons.person,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width * 0.14,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Influencer Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double fontSize = largeFontSize + 6; // Default font size
                            double availableWidth = name.length*largeFontSize;
                            //print('$fontSize $availableWidth ${MediaQuery.of(context).size.width * 0.38*2}');

                            if (availableWidth > MediaQuery.of(context).size.width * 0.38*2) {
                              fontSize = normFontSize; // Adjust this to your needs
                            }

                            return Text(
                              name,
                              style: TextStyle(
                                fontSize: fontSize, // Adjusted font size
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(5, 50, 70, 1.0),
                              ),
                              overflow: TextOverflow.ellipsis, // Truncate with ellipsis if the text overflows
                              softWrap: false, // Prevent wrapping
                            );
                          },
                        ),
                        Text(
                          designation, // Dynamic designation
                          style: TextStyle(
                            fontSize: smallFontSize,
                            color: Color.fromRGBO(5, 50, 70, 1.0),
                          ),
                        ),
                        Text(
                          description, // Dynamic designation
                          style: TextStyle(
                            fontSize: smallFontSize,
                            color: Color.fromRGBO(5, 50, 70, 1.0),
                          ),
                        ),
                        Text(
                          hashtags, // Dynamic designation
                          style: TextStyle(
                            fontSize: smallFontSize,
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
                  fontSize: smallFontSize - 3,  // Font size for "L"
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
                  fontSize: smallFontSize - 3,  // Font size for "L"
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
