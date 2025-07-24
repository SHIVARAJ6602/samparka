import 'dart:async';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samparka/Screens/view_influencers.dart';

import '../Service/api_service.dart';
import '../widgets/influencer_card.dart';
import 'add_influencer.dart';
import 'my_team.dart';

class MigrateInfluencerPage1 extends StatefulWidget {
  final String id;

  const MigrateInfluencerPage1(this.id, {super.key});

  @override
  _MigrateInfluencerPageState1 createState() => _MigrateInfluencerPageState1();
}

class _MigrateInfluencerPageState1 extends State<MigrateInfluencerPage1> {
  final apiService = ApiService();


  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();// search focus node

  bool isSearching = false;
  List<dynamic> influencers = [];
  List<dynamic> infSearched = [];
  List<dynamic> unApprovedInfluencers = [];
  late List<dynamic> result;
  bool loading = true;
  bool assign = false;
  bool assignGatanayak = false;
  List<dynamic> TeamMembers = [];
  List<dynamic> Gatanayaks = [];
  //List<dynamic> ApproveMember = [];
  Map<String, dynamic> ApproveMember = {};
  int selectedMemberIndex = -1;
  int? selectedIndex;
  Timer? _debounce;
  List<dynamic> hashtags = [];

  bool migrateMyInfluencers = false;
  bool migrateShreniPramukhInfluencers = false;
  bool migrateGatanayakInfluencers = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchHashtags() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getHashtags();
      setState(() {
        hashtags = result;
        //log('hashtags\'s $result');
      });
    } catch (e) {
      log("Error fetching influencers: $e");
    }
  }

  Future<bool> fetchInfluencers() async {
    try {
      setState(() {
        print('fetch called inf');
        loading = true;
      });
      // Call the apiService.homePage() and store the result
      result = await apiService.homePage();
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
        print(influencers);
      });
      return true;
    } catch (e) {
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
    return false;
  }

  Future<void> fetchTeam() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getShreniPramukhs(apiService.UserId);
      setState(() {
        // Update the influencers list with the fetched data
        TeamMembers = result;
        //TeamMembers.add({'id':apiService.UserId,'first_name':'${apiService.first_name}(self)','last_name':apiService.last_name,'designation':apiService.designation,'profileImage':apiService.profileImage});
        //log('ShreniPramukhs: $TeamMembers');
      });
    } catch (e) {
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
  }

  Future<void> fetchGatanayak(String KR_id) async {
    try {
      result = await apiService.getGatanayak(KR_id);
      setState(() {
        // Update the influencers list with the fetched data
        Gatanayaks = result;
        //TeamMembers.add({'id':apiService.UserId,'first_name':'${apiService.first_name}(self)','last_name':apiService.last_name,'designation':apiService.designation,'profileImage':apiService.profileImage});
      });
    } catch (e) {
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
  }

  String _latestSearch = '';
  Future<void> search(String str) async {
    _latestSearch = str; // Save the latest user input

    try {
      var inf = await apiService.searchGV(str);

      // Check if this result still matches the latest search input
      if (_latestSearch != str) {
        return; // Ignore stale results
      }

      if (inf is List) {
        //("inf length: ${inf.length}");
        inf.forEach((inf) {
          if (inf['soochi'] == 'AkhilaBharthiya') inf['soochi'] = 'AB';
          else if (inf['soochi'] == 'PranthyaSampark') inf['soochi'] = 'PS';
          else if (inf['soochi'] == 'JillaSampark') inf['soochi'] = 'JS';

          if (inf['interaction_level'] == 'Sampark') inf['interaction_level'] = 'S1';
          else if (inf['interaction_level'] == 'Sahavas') inf['interaction_level'] = 'S2';
          else if (inf['interaction_level'] == 'Samarthan') inf['interaction_level'] = 'S3';
          else if (inf['interaction_level'] == 'Sahabhag') inf['interaction_level'] = 'S4';
        });

        setState(() {
          infSearched = inf;
        });
      } else if (inf == false) {
        setState(() {
          infSearched = [];
        });
      }
    } catch (e) {
      log("Error fetching Karyakartha: $e");
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

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage()  async {
    await fetchInfluencers();
    fetchGatanayak(widget.id);
    fetchTeam();
    setState(() {
      loading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        title: Text('Migrate Influencer'),
      ),
      body: Stack(
        children: [
          if (isSearching)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12), // Container padding
                width: MediaQuery.of(context).size.width * 1.0,
                height: MediaQuery.of(context).size.height * 1.0,
                child: Column(
                  children: [
                    //SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(217, 217, 217, 1.0),
                        hintText: 'Search Influencer to Migrate',
                        hintStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.041,
                          fontWeight: FontWeight.normal,
                          color: Color.fromRGBO(128, 128, 128, 1.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(60, 245, 200, 1.0),
                                  Color.fromRGBO(2, 40, 60, 1),
                                ],
                              ),
                            ),
                            child: const Icon(Icons.search, color: Colors.white),
                          ),
                        ),
                      ),
                      onChanged: (text) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();

                        _debounce = Timer(Duration(milliseconds: 300), () {
                          if (text.isNotEmpty) {
                            infSearched = [];
                            search(text);
                          }
                        });
                      },

                      onTap: () {
                        isSearching = true;
                      },
                    ),
                    SizedBox(height: 25),
                    //Search Profiles
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
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                              ),
                            )
                          else
                            if (infSearched.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'No Influencer Found',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.041+2,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                height: (infSearched.length <= 3) ? MediaQuery.of(context).size.height * 0.52 : MediaQuery.of(context).size.height * 0.62,
                                padding: const EdgeInsets.all(1), // Optional, for spacing inside the container
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: (infSearched.length <= 3)
                                    ? Column(
                                  children: List.generate(
                                    infSearched.length,
                                        (index) {
                                      final influencer = infSearched[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8, top: 20, bottom: 10),
                                        child: InfluencerCard(
                                          id: influencer['id'] ?? '',
                                          name: "${influencer['fname'] ?? ''} ${influencer['lname'] ?? ''}".trim(),
                                          designation: influencer['designation'] ?? '',
                                          description: influencer['description'] ?? '',
                                          hashtags: getHashtagNames(influencer['hashtags'], hashtags),
                                          soochi: influencer['soochi'] ?? '',
                                          shreni: influencer['shreni'] ?? '',
                                          itrLvl: influencer['interaction_level'] ?? '',
                                          profileImage: (influencer['profile_image'] ?? '').toString(),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                    : SingleChildScrollView(
                                  child: Column(
                                    children: List.generate(
                                      infSearched.length,
                                          (index) {
                                        final influencer = infSearched[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10),
                                          child: InfluencerCard(
                                            id: influencer['id'] ?? '',
                                            name: "${influencer['fname'] ?? ''} ${influencer['lname'] ?? ''}".trim(),
                                            designation: influencer['designation'] ?? '',
                                            description: influencer['description'] ?? '',
                                            hashtags: getHashtagNames(influencer['hashtags'], hashtags),
                                            soochi: influencer['soochi'] ?? '',
                                            shreni: influencer['shreni'] ?? '',
                                            itrLvl: influencer['interaction_level'] ?? '',
                                            profileImage: (influencer['profile_image'] ?? '').toString(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if(loading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (!isSearching)
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //Search Bar
                        if(!isSearching)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isSearching = true;
                                _focusNode.requestFocus();
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // Remove padding to make the button's content tight
                              backgroundColor: const Color.fromRGBO(217, 217, 217, 1.0), // Same as TextField background color
                              minimumSize: Size(double.infinity, 48), // Ensure the button is appropriately sized
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Same border radius as the TextField
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '     Search Influencer to Migrate', // The text inside the button, just like the hintText in TextField
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.041,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromRGBO(128, 128, 128, 1.0),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color.fromRGBO(60, 245, 200, 1.0),
                                          Color.fromRGBO(2, 40, 60, 1),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(Icons.search, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        //Migrate my influencers
                        Text('Influencers',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.041 *3,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(5, 50, 70, 1.0),
                          ),
                        ),
                        const SizedBox(height: 1),
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
                            onPressed: () {
                              setState(() {
                                migrateMyInfluencers = !migrateMyInfluencers;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 0,right: 0, bottom: 10,top: 10), // Remove padding to fill the entire container
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                            ),
                            child: Center(
                              child: Text(
                                'Migrate Assigned Influencer',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.041+7,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 1),
                        //My Influencers
                        if(migrateMyInfluencers)
                          Column(
                            children: [
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
                                        child: CircularProgressIndicator(
                                          backgroundColor: Colors.blue,
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
                                              'No Influencer To Migrate',
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
                                                  id: influencer['id']??'',
                                                  name: '${influencer['fname']} ${influencer['lname']}'??'',
                                                  designation: influencer['designation']??'',
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
                                        ),
                                    if (influencers.isNotEmpty)
                                    // View All Influencers Button
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ViewInfluencersPage(apiService.UserId)),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'View all My Influencers',
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
                            ],
                          ),


                        //My Shreni Pramukhs
                        if(apiService.lvl > 2)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                'Shreni Pramukhs',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: largeFontSize * 2,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromRGBO(5, 50, 70, 1.0),
                                ),
                                minFontSize: largeFontSize.floorToDouble(),
                                stepGranularity: 1.0,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              //migrate button
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
                                  onPressed: () {
                                    setState(() {
                                      migrateShreniPramukhInfluencers = !migrateShreniPramukhInfluencers;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 0,right: 0, bottom: 10,top: 10), // Remove padding to fill the entire container
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Migrate Shreni Pramukhs Influencer',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.041+7,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 1),
                              if(migrateShreniPramukhInfluencers)
                                Container(
                                  decoration: BoxDecoration(
                                    //borderRadius: BorderRadius.circular(30),
                                    borderRadius: TeamMembers.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
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
                                      if (TeamMembers.isEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'No Members Assigned',
                                              style: TextStyle(
                                                fontSize: largeFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      // If the list is not empty, build a ListView of InfluencerCards
                                      else
                                        Column(
                                          children: List.generate(
                                            (TeamMembers.length < 4) ? TeamMembers.length : 3, // Display either all members or just 3
                                                (index) {
                                              final member = TeamMembers[index]; // Access the member data
                                              return Padding(
                                                padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                                child: MemberCard(
                                                  id: member['id']!,
                                                  first_name: member['first_name']!,
                                                  last_name: member['last_name']!,
                                                  designation: member['designation']??"Not Set",
                                                  profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                      ? member['profile_image']!
                                                      : '',
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                      if (TeamMembers.isNotEmpty)
                                      // View All Influencers Button
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const MyTeamPage(type: 'ShreniPramukh')),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'View all Members',
                                                style: TextStyle(
                                                  fontSize: largeFontSize,
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
                            ],
                          ),
                        //My Gatanayak
                        if(apiService.lvl>1)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                'Gatanayaks',
                                style: TextStyle(
                                  fontSize: largeFontSize*2,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromRGBO(5, 50, 70, 1.0),
                                ),
                              ),
                              const SizedBox(height: 1),
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
                                  onPressed: () {
                                    setState(() {
                                      migrateGatanayakInfluencers = !migrateGatanayakInfluencers;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 0,right: 0, bottom: 10,top: 10), // Remove padding to fill the entire container
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Migrate Gatanayaks Influencer',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.041+7,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 1),
                              if(migrateGatanayakInfluencers)
                                Container(
                                  decoration: BoxDecoration(
                                    //borderRadius: BorderRadius.circular(30),
                                    borderRadius: Gatanayaks.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
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
                                      if (Gatanayaks.isEmpty)
                                        Container(
                                          padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'No Gatanayak Assigned',
                                              style: TextStyle(
                                                fontSize: largeFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      // If the list is not empty, build a ListView of InfluencerCards
                                      else
                                        Column(
                                          children: List.generate(
                                            (Gatanayaks.length < 4) ? Gatanayaks.length : 3, // Display either all members or just 3
                                                (index) {
                                              final member = Gatanayaks[index]; // Access the member data
                                              //log("Gatanayak $member ${Gatanayaks.length}");
                                              return Padding(
                                                padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                                child: MemberCard(
                                                  id: member['id']!,
                                                  first_name: member['first_name']!,
                                                  last_name: member['last_name']!,
                                                  designation: member['designation']??"Not Set",
                                                  profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                      ? member['profile_image']!
                                                      : '',
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                      if (Gatanayaks.isNotEmpty)
                                      // View All Influencers Button
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const MyTeamPage(type: 'Gatanayaks',)),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'View all Members',
                                                style: TextStyle(
                                                  fontSize: largeFontSize,
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
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
        ],
      ),
    );
  }
}