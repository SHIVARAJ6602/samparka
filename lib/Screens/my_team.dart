import 'package:flutter/material.dart';

import '../Service/api_service.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  final ApiService apiService = ApiService();

  List<dynamic> TeamMembers = [];
  late List<dynamic> result;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTeam();
    loading = false;
  }

  // Define a function to fetch data
  Future<void> fetchTeam() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.myInfluencer(0, 100);
      setState(() {
        // Update the influencers list with the fetched data
        TeamMembers = result;
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Team'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: TeamMembers.length,
        itemBuilder: (context, index) {
          final teamMember = TeamMembers[index];
          print('name: ${teamMember['fname']}');
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MemberCard(
              name: teamMember['fname']!,
              designation: teamMember['designation']!,
              description: teamMember['description']!,
              hashtags: teamMember['hashtags']!,
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
          child: MemberCard(
            name: influencer['fname']!,
            designation: influencer['designation']!,
            description: influencer['description']!,
            hashtags: influencer['hashtags']!,
          ),
        );
      },
    );
  }
}


class MemberCard extends StatelessWidget {
  final String name;
  final String designation;
  final String description;
  final String hashtags;

  const MemberCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Profile Picture (placeholder)
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
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
                SizedBox(height: 1),
                Text(
                  description, // Dynamic description
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(5, 50, 70, 1.0),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1),
                Text(
                  hashtags, // Dynamic hashtags
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
