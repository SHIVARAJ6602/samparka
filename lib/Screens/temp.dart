import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TempPage extends StatefulWidget {
  @override
  _HamburgerMenuPageState createState() => _HamburgerMenuPageState();
}

class _HamburgerMenuPageState extends State<TempPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        title: Text('Test'),
      ),
      body: InfluencerList(),
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
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
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

  const InfluencerCard({
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
