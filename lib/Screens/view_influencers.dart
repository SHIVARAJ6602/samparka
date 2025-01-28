import 'dart:convert';

import 'package:flutter/material.dart';

import '../Service/api_service.dart';

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
      setState(() {
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
              name: influencer['fname']!,
              designation: influencer['designation']!,
              description: influencer['description']!,
              hashtags: influencer['hashtags']!,
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
            name: influencer['fname']!,
            designation: influencer['designation']!,
            description: influencer['description']!,
            hashtags: influencer['hashtags']!,
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
  final String name;
  final String designation;
  final String description;
  final String hashtags;
  final String profileImage;

  const InfluencerCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags, required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          print('object');
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
    );
  }
}
