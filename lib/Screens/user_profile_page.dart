import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:samparka/Screens/schedule_interaction.dart';
import 'package:samparka/Screens/view_influencers.dart';
import 'package:samparka/Screens/view_interaction.dart';
import 'package:samparka/Screens/view_report_meetings.dart';

import '../Service/api_service.dart';
import '../widgets/influencer_card.dart';

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
  late String hashtags = '';
  late String profileImage = '';
  late String shreni = '';
  late int level = 0;
  late String KR_id = '';

  DateTime? selectedFromDate;
  DateTime? selectedToDate;
  late var selectedMeetingType = "Meeting";
  int influencerCount = 0;
  int influencerMet = 0;
  int activeTeamMembers = 0;
  int inactiveTeamMembers = 0;
  int individualMeetings = 0;
  int SGM = 0;
  int programs = 0;
  int baitek = 0;
  int successfullMeetings = 0;
  List<dynamic> data = [];


  List<dynamic> influencers = [];

  TextEditingController titleController = TextEditingController();

  late bool loading = true;

  Future<void> fetchInfluencers() async {
    try {
      // Call the apiService.homePage() and store the result
      resultGV = await apiService.getInfluencer(0, 100,widget.id);
      result = [];
      //log('Influencers User Screen $result');
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
      log("Error fetching influencers: $e");
    }
  }

  List<dynamic> fetchedHashtags = [];
  bool isTagsLoaded = false;
  Future<void> fetchHashtags() async {
    try {
      // Call the apiService.homePage() and store the result
      var tags = await apiService.getHashtags();
      setState(() {
        fetchedHashtags = tags;
        //log('hastags\'s $result');
        isTagsLoaded = true;
      });

    } catch (e) {
      log("Error fetching tags: $e");
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
    _loadData();
  }

  Future<void> _loadData() async {
    fetchHashtags();
    setState(() {loading = true;});
    KR_id = widget.id;
    getKaryakartha();
    fetchInfluencers();
    fetchTasks(KR_id);
    setState(() {});
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        //loading = false;
      });
    });
  }

  Future<void> _getReport() async{
    try {
      // Call the apiService.homePage() and store the result
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfRange = now;
      result = await apiService.getReportPage(widget.id,startOfMonth.toIso8601String(),endOfRange.toIso8601String());
      setState(() {
        data = result;
        if (data != null && data.isNotEmpty) {
          var report = data[0];
          int totalKR = report['Total_KR'] ?? 0;
          int activeKR = report['Active_KR'] ?? 0;

          setState(() {
            influencerCount = report['Total_GV'] ?? 0;
            influencerMet = report['Met_GV'] ?? 0;
            activeTeamMembers = activeKR;
            inactiveTeamMembers = totalKR - activeKR;
            successfullMeetings = totalKR;

            individualMeetings = report['Individual'] ?? 0;
            SGM = report['SGM'] ?? 0;
            programs = report['Program'] ?? 0;
            baitek = report['Baitek'] ?? 0;
          });
        }
      });
    } catch (e) {
      // Handle any errors here
      log("Error fetching Report in Page(User profile page): $e");
    }
  }

  Future<bool> getKaryakartha() async{
    try {
      // Call the apiService.homePage() and store the result
      resultKR = await apiService.getKaryakartha(KR_id);
      setState(() {
        // Update the influencers list with the fetched data
        //meetings = result;
        //log("result $resultKR");
        name = '${resultKR[0]['first_name']} ${resultKR[0]['last_name']}';
        designation = resultKR[0]['designation'];
        description = resultKR[0]['description'] ?? '';
        profileImage = resultKR[0]['profile_image'] ?? '';
        shreni = resultKR[0]['shreni'] ?? '';
        level = int.tryParse(resultKR[0]['level']?.toString() ?? '0') ?? 0;
        if(level>2){
          _getReport();
        }
        //log('KR loaded');
        setState(() {
          loading = false;
        });
      });
      return true;
    } catch (e) {
      // Handle any errors here
      log("Error fetching karyakartha: $e");
    }
    return false;
  }

  void _viewMeets(type) {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfRange = now;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewReportMeetingsPage(type,startOfMonth.toIso8601String(),endOfRange.toIso8601String())),
    );
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
      log("Error fetching interactions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String GV_id = widget.id;
    //log(GV_id);
    //log(widget.id);
    //log("profile image: $profileImage");
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        actions: [
          // Add the notification icon to the right side of the app bar
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromRGBO(5, 50, 70, 1.0)), // Notification icon
            onPressed: () {
              // Handle the notification icon tap here (you can add navigation or other actions)
              //log('Notifications tapped');
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
                                width: (MediaQuery.of(context).size.width * 0.80) / 3.0,  // 90% of screen width divided by 3 images
                                height: (MediaQuery.of(context).size.width * 0.80) / 3.0,  // Fixed height for each image
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
                                        color: Colors.white,  // Placeholder color for invalid image URLs
                                        child: Center(
                                          child: Icon(Icons.error, color: Colors.grey),  // Display error icon
                                        ),
                                      );
                                    },
                                  )
                                      : Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: MediaQuery.of(context).size.width * 0.22,
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      designation, // Dynamic designation
                                      style: TextStyle(
                                        fontSize: smallFontSize,
                                        color: Color.fromRGBO(5, 50, 70, 1.0),
                                      ),
                                    ),
                                    /*Container(
                                      width: 2, // Divider width
                                      height: smallFontSize, // Divider height (you can adjust this as needed)
                                      color: Colors.black, // Divider color
                                      margin: EdgeInsets.symmetric(horizontal: 8), // Add spacing around the divider
                                    ),*/
                                    if(level < 3)
                                    Text(
                                      shreni, // Dynamic designation
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
                      //report
                      if (level>2)
                        Column(
                        children: [
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('This Month\'s Overview',style: TextStyle(fontWeight: FontWeight.bold,fontSize: largeFontSize+10,color: Color.fromRGBO(2, 40, 60, 1),decoration: TextDecoration.underline),),
                              ],
                            ),
                          ),
                          //Meeting Summary
                          Container(
                            width: MediaQuery.of(context).size.width-20,
                            padding: const EdgeInsets.all(16.0), // Padding around the container
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1, // Border width
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(60, 245, 200, 1.0),
                                  Color.fromRGBO(2, 40, 60, 1),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        width: MediaQuery.of(context).size.width*0.40,
                                        padding: const EdgeInsets.all(7.0),
                                        decoration: BoxDecoration(
                                          //color: Color.fromRGBO(255, 255, 255, 0.1), // Background color
                                          borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                          border: Border.all(
                                            color: Colors.grey.shade400, // Border color
                                            width: 1, // Border width
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed: (){
                                            if(individualMeetings>0){
                                              _viewMeets('individual');
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Text('$individualMeetings',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: largeFontSize*1.85,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),),
                                              Text('Individual Meetings',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: normFontSize,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),textAlign: TextAlign.center,),
                                              //Text('data',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                            ],
                                          ),
                                        )
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                        width: MediaQuery.of(context).size.width*0.40,
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          //color: Color.fromRGBO(255, 255, 255, 0.3), // Background color
                                          borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                          border: Border.all(
                                            color: Colors.grey.shade400, // Border color
                                            width: 1, // Border width
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed: (){
                                            if(SGM>0){
                                              _viewMeets('sgm');
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Text('$SGM',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: largeFontSize*2,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),),
                                              Text('Small Group Meetings ',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: normFontSize,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),textAlign: TextAlign.center,),
                                              //Text('data',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                            ],
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                        width: MediaQuery.of(context).size.width*0.40,
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          //color: Color.fromRGBO(255, 255, 255, 0.3), // Background color
                                          borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                          border: Border.all(
                                            color: Colors.grey.shade400, // Border color
                                            width: 1, // Border width
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed: (){
                                            if(programs>0){
                                              _viewMeets('program');
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Text('$programs',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: largeFontSize*2,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),),
                                              Text('Programs',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: normFontSize,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),textAlign: TextAlign.center,),
                                            ],
                                          ),
                                        )
                                    ),
                                    SizedBox(width: 5),
                                    Divider(),
                                    SizedBox(width: 5),
                                    Container(
                                        width: MediaQuery.of(context).size.width*0.40,
                                        padding: const EdgeInsets.all(5.0),
                                        decoration: BoxDecoration(
                                          //color: Color.fromRGBO(255, 255, 255, 0.3), // Background color
                                          borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                          border: Border.all(
                                            color: Colors.grey.shade400, // Border color
                                            width: 1, // Border width
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed: (){
                                            if(baitek>0){
                                              _viewMeets('baitak');
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Text('$baitek',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: largeFontSize*2,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),),
                                              Text('Baitaks',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: normFontSize,shadows: [Shadow(color: Colors.black.withOpacity(0.5),offset: Offset(3.0, 3.0),blurRadius: 5.0,),]),textAlign: TextAlign.center,),
                                            ],
                                          ),
                                        )
                                    ),
                                  ],
                                )
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
                                      //log(influencer['hashtags']);
                                      //log('influencer ${influencer??[]}');
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                        child: InfluencerCard(
                                          id: influencer['id']!,
                                          name: influencer['fname']??'',
                                          designation: influencer['designation']!,
                                          description: influencer['description']??'',
                                          //hashtags: influencer['hashtags']??'',
                                          hashtags: getHashtagNames(influencer['hashtags'], fetchedHashtags),
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