import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Service/api_service.dart';
import '../widgets/influencer_card.dart';

class ViewInfluencersPage extends StatefulWidget {
  final String id;

  const ViewInfluencersPage(this.id,{super.key});

  @override
  ViewInfluencersPageState createState() => ViewInfluencersPageState();
}

class ViewInfluencersPageState extends State<ViewInfluencersPage> {
  final apiService = ApiService();

  List<dynamic> influencers = [];
  late List<dynamic> result;
  bool loading = true;
  List<dynamic> hashtags = [];

  @override
  void initState() {
    super.initState();
    fetchHashtags();
    fetchInfluencers();
    loading = false;
  }

  Future<void> fetchHashtags() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getHashtags();
      setState(() {
        hashtags = result;
        //('hashtags\'s $result');
      });
    } catch (e) {
      log("Error fetching influencers: $e");
    }
  }

  String getHashtagNames(dynamic influencerHashtagIds, dynamic allHashtags) {
    final List<int> ids = List<int>.from(influencerHashtagIds ?? []);
    final List<Map<String, dynamic>> hashtags =
    List<Map<String, dynamic>>.from(allHashtags ?? []);

    final matchedNames = ids.map((id) {
      final tag = hashtags.firstWhere(
            (tag) => tag['id'] == id,
        orElse: () => {},
      );
      final name = tag['name'];
      return name != null ? '#$name' : '';
    }).where((name) => name.isNotEmpty).join(', ');

    return matchedNames;
  }

  // Define a function to fetch data
  Future<void> fetchInfluencers() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getInfluencer(0, 100,widget.id);
      //log(result);
      setState(() {
        for (var inf in result) {
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
        }
        // Update the influencers list with the fetched data
        influencers = result;
      });
    } catch (e) {
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    largeFontSize = largeFontSize;
    smallFontSize = smallFontSize;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        title: Text('Influencers'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: influencers.length,
        itemBuilder: (context, index) {
          final influencer = influencers[index];
          //log('name: ${influencer['fname']}');
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: InfluencerCard(
              id: influencer['id']!,
              name: '${influencer['fname'] ?? ''} ${influencer['lname'] ?? '.'}',
              designation: influencer['designation']!,
              description: influencer['description']??'',
              //hashtags: influencer['hashtags']??'',
              hashtags: getHashtagNames(influencer['hashtags'], hashtags),
              soochi: influencer['soochi']??'',
              shreni: influencer['shreni']??'',
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
        //log('name: ${influencer['fname']}');
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: InfluencerCard(
            id: influencer['id']!,
            name: influencer['fname']!,
            designation: influencer['designation']!,
            description: influencer['description']!,
            hashtags: influencer['hashtags']!,
            soochi: influencer['soochi']??'',
            shreni: influencer['shreni']??'',
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
