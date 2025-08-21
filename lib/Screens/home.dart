import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badges/badges.dart' as badges;
import 'package:samparka/Screens/meeting.dart';
import 'package:samparka/Screens/profile_page.dart';
import 'package:samparka/Screens/team.dart';
import 'package:samparka/Screens/view_meeting.dart';
import '../Service/app_notification_service.dart';
import '../utils/global_navigator_key.dart';
import '../widgets/approval_card.dart';
import '../widgets/influencer_card.dart';
import '../widgets/menu_drawer.dart';
import 'add_influencer.dart';
import 'event_detail.dart';
import 'gen_report.dart';
import 'help.dart';
import 'login.dart';
import 'api_test.dart'; //TaskListScreen()
import 'notifications.dart';
import 'view_influencers.dart';
import 'package:samparka/Service/api_service.dart';

class InfluencersPage extends StatefulWidget {
  const InfluencersPage({super.key});

  @override
  _InfluencersPageState createState() => _InfluencersPageState();
}

class _InfluencersPageState extends State<InfluencersPage> {
  // This keeps track of the selected index for the bottom navigation
  int _selectedIndex = 0;
  final apiService = ApiService();
  final FocusNode _focusNode = FocusNode();// search focus node

  // Method to handle bottom navigation item tap
  void _onNavItemTapped(int index) {

    if (index == 5) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else if (index == 4) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApiScreen()),
      );
    } else if (index == 3) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        //MaterialPageRoute(builder: (context) => const TempPage2()),
        MaterialPageRoute(builder: (context) => const GenReportPage()),
      );
    } else if (index == 2) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MeetingPage()),
      );
    } else if (index == 1) {
      // Navigate to AddInfluencerPage when index 1 is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TeamPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index; // Update the selected index for other tabs
      });
    }
  }
  /****************menu**********************/
  // Text editing controllers for text fields
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController newUrlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late String username;
  late bool isAuthenticated;
  late String token;
  late int level;
  late String currentUrl;
  List<dynamic> influencers = [];
  List<dynamic> infSearched = [];
  bool isSearching = false;
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
  List<dynamic> hashtags = [];
  Timer? _debounce;


  late String soochi;

  int unreadCount = 0; //notification

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    handleAuth(context);
    //handleButtonPress();
    //apiService.token = 'c7117b29e594dda83130774d398a928021810c41';
    //apiService.getUser(context);
    username = apiService.first_name;
    isAuthenticated = apiService.isAuthenticated;
    token = apiService.token;
    level = apiService.lvl;
    currentUrl = apiService.baseUrl;
    fetchHashtags();
    fetchInfluencers();
    if(apiService.lvl>2){
      getUnapprovedProfile();
    }
    updateBadge();
    //fetchTeam();
    setState(() {loading = false;});
  }

  void updateBadge() async {
    //Future.delayed(Duration.zero, );
    final count = await AppNotificationService.getUnreadCount();
    setState(() { unreadCount = count; });
    setState(() { unreadCount = 2; });
  }

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
        //log('hastags\'s $result');
      });
    } catch (e) {
      log("Error fetching influencers: $e");
    }
  }

  // State variables for radio buttons
  String? selectedRadio = 'url1';

  Future<void> handleAuth(BuildContext context) async {
    if (!await apiService.getUser(context)) {
      // Wait for 2 seconds before dismissing and navigating
      await Future.delayed(const Duration(seconds: 2));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false, // removes all previous routes
        );
      });

    }
  }

  // Function to handle button press logic
  void handleButtonPress() {
    setState(() {
      if (newUrlController.text.isNotEmpty) {
        currentUrl = newUrlController.text;
      } else {
        currentUrl = selectedRadio == 'url1' ? apiService.baseUrl1 : apiService.baseUrl2;
      }
      apiService.baseUrl = currentUrl;
      apiService.saveData();
    });

    // Logic for what should happen on button press
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('URL changed!'),
        content: Text('Current URL: $currentUrl'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Define a function to fetch data
  Future<bool> fetchInfluencers() async {
    try {
      setState(() {
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
      });
      return true;
    } catch (e) {
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
    return false;
  }

  Future<bool> getUnapprovedProfile() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.get_unapproved_profiles();
      if (result.isNotEmpty) {
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
        setState(() {
          // Update the influencers list with the fetched data
          unApprovedInfluencers = result;
          //log('UnApproved Profile: $unApprovedInfluencers');
        });
      } else {
        setState(() {
          unApprovedInfluencers = [];  // Clear the list if result is empty
        });
      }


      return true;
    } catch (e) {
      unApprovedInfluencers = [];
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
    setState(() {});
    return false;
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

  Future<void> fetchTeam() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getShreniPramukhs(apiService.UserId);
      setState(() {
        // Update the influencers list with the fetched data
        TeamMembers = result;
        TeamMembers.add({'id':apiService.UserId,'first_name':'${apiService.first_name}(self)','last_name':apiService.last_name,'designation':apiService.designation,'profileImage':apiService.profileImage});
        //log('ShreniPramukhs: $TeamMembers');
      });
    } catch (e) {
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
  }

  Future<void> fetchGatanayak(String KR_id) async {
    try {
      setState(() {
        loading=true;
      });
      // Call the apiService.homePage() and store the result
      result = await apiService.getGatanayak(KR_id);
      setState(() {
        // Update the influencers list with the fetched data
        Gatanayaks = result;
        //TeamMembers.add({'id':apiService.UserId,'first_name':'${apiService.first_name}(self)','last_name':apiService.last_name,'designation':apiService.designation,'profileImage':apiService.profileImage});
        //log('Gatanayaks: $Gatanayaks');
        loading=false;
        if(Gatanayaks.isEmpty){
          assignGatanayak=false;
          assign=true;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Information'),
                content: Text('No Gatanayak Found for the Profile'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      });
    } catch (e) {
      // Handle any errors here
      loading=false;
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

  Future<bool> getKaryakartha(String KR_id) async{
    try {
      // Call the apiService.homePage() and store the result
      var resultKR = await apiService.getKaryakartha(KR_id);
      setState(() {
        // Update the influencers list with the fetched data
        //meetings = result;

        setState(() {});

      });
      return true;
    } catch (e) {
      // Handle any errors here
      log("Error fetching karyakartha: $e");
    }
    return false;
  }

  void createdMember(String id) {
    final index = TeamMembers.indexWhere((member) => member['id'] == id);

    if (index != -1) {
      selectedMemberIndex = index;
      log('Selected member index: $selectedMemberIndex');
    } else {
      log('Member with ID $id not found.');
    }
  }



  /// ***************************************************

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: apiService.lvl <= 2
                ? IconButton(
              icon: Transform.rotate(
                angle: 3.1416,
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Color.fromRGBO(5, 50, 70, 1.0),
                ),
              ),
              onPressed: () {
                SystemNavigator.pop(); // This exits the app
              },
            ):null,
            /*
            leading: apiService.lvl > 2
                ? IconButton(
              icon: const Icon(Icons.person, color: Color.fromRGBO(5, 50, 70, 1.0)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            )
                : IconButton(
              icon: Transform.rotate(
                      angle: 3.1416,
                      child: const Icon(
                        Icons.exit_to_app_rounded,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                onPressed: () {
                SystemNavigator.pop(); // This exits the app
              },
            ),*/
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            elevation: 0,
            title: Text('Samparka',style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              // 🆕 Help icon added before notification
              IconButton(
                icon: const Icon(Icons.bug_report, color: Color.fromRGBO(5, 50, 70, 1.0)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpPage()), // Your help/feedback screen
                  );
                },
              ),
              // Notification icon
              IconButton(
                icon: badges.Badge(
                  badgeContent: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 10),
                  ),
                  showBadge: unreadCount > 0,
                  child: Icon(Icons.notifications, color: Color.fromRGBO(5, 50, 70, 1.0)),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsPage()),
                  );
                  updateBadge(); // refresh on return from notifications page
                },
              ),
            ],
          ),
          /**************menu***********************/
          drawer: MenuDrawer(apiService: apiService),
          /***************************menu end*************************************/
          body: Stack(
            children: [
              // Main content inside a SingleChildScrollView
              if(!isSearching)
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //const SizedBox(height: 50),
                          // Search Bar
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
                                      '     Search Influencer', // The text inside the button, just like the hintText in TextField
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
                          TextButton(
                              onPressed: () async {
                                final id = 'BT00000007';
                                final typeId = '1';
                                Map<String, dynamic> eventData;

                                Future<Map<String, dynamic>> fetchEventData() async {
                                  try {
                                    final apiService = ApiService();
                                    final result = await apiService.getEventByID(id, typeId);
                                    if (result.isNotEmpty) {
                                      return eventData = result[0];
                                    }
                                  } catch (e) {
                                    log("Error loading event: $e");
                                  }
                                  return {}; // Return empty map if error occurs or result is empty
                                }
                                eventData = await fetchEventData();
                                navigatorKey.currentState?.push(
                                  MaterialPageRoute(
                                    builder: (_) => ViewEventPage(id, eventData,typeId),
                                  ),
                                );
                              },
                              child: Text('data')
                          ),
                          if(!isSearching)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //Approve and assign
                                if(apiService.lvl > 2)
                                  Column(
                                    children: [
                                      const SizedBox(height: 22),
                                      if (unApprovedInfluencers.isNotEmpty)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // approval & assign Influencers Title
                                            Text(
                                              'Approval & Assign',
                                              style: TextStyle(
                                                fontSize: largeFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromRGBO(5, 50, 70, 1.0),
                                              ),
                                            ),
                                            Text(
                                              'Influencers',
                                              style: TextStyle(
                                                fontSize: largeFontSize*2.5,
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromRGBO(5, 50, 70, 1.0),
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            // approval Cards
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal, // Horizontal scrolling
                                              child: Row(
                                                children: List.generate(unApprovedInfluencers.length, (index) {
                                                  final influencer = unApprovedInfluencers[index]; // Access the influencer data for each item
                                                  return Padding(
                                                    padding: const EdgeInsets.only(left: 1, right: 8, top: 8, bottom: 8), // Adjust horizontal padding
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width * 0.75,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30),
                                                        gradient: const LinearGradient(
                                                          begin: Alignment.centerRight,
                                                          end: Alignment.centerLeft,
                                                          colors: [
                                                            Color.fromRGBO(60, 170, 145, 1.0),
                                                            Color.fromRGBO(2, 40, 60, 1),
                                                          ],
                                                        ),
                                                      ),
                                                      child: ApprovalCard(
                                                        name: '${influencer['fname']} ${influencer['lname']}',
                                                        designation: influencer['designation']??"Not Set",
                                                        description: influencer['description']??"Not Set",
                                                        //hashtags: influencer['hashtags']!,
                                                        shreni: influencer['shreni']??"Not Set",
                                                        hashtags: getHashtagNames(influencer['hashtags'], hashtags),
                                                        imageUrl: influencer['profile_image'] != null && influencer['profile_image']!.isNotEmpty
                                                            ? influencer['profile_image']!
                                                            : '',
                                                        onPress: () {
                                                          setState(() {
                                                            fetchTeam();
                                                            selectedIndex = index;
                                                            ApproveMember = unApprovedInfluencers[index];
                                                            //log('index $selectedIndex');
                                                            assign = true;
                                                          });
                                                          createdMember(ApproveMember['created_by']);
                                                          //log('Selected index: $selectedIndex'); // log selected index
                                                        },
                                                        soochi: influencer['soochi']??'',
                                                        itrLvl: influencer['interaction_level']??'',
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                if (unApprovedInfluencers.isNotEmpty)
                                const SizedBox(height: 20),
                                // Recently Assigned Influencers Title
                                Text(
                                  'Recently Assigned',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.041+2,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                ),
                                Text('Influencers',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width * 0.041 *3,
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
                                                    id: influencer['id']??'',
                                                    name: '${influencer['fname']} ${influencer['lname']}',
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

                                //Add new Influencer Button
                                const SizedBox(height: 20),
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AddInfluencerPage()),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.only(left: 0,right: 0, bottom: 10,top: 10), // Remove padding to fill the entire container
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Add New Influencer',
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width * 0.041+7,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                //const SizedBox(height: 16),

                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if(assign)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withAlpha(180),
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.65,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Color.fromRGBO(60, 170, 145, 1.0),
                              Color.fromRGBO(2, 40, 60, 1),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Main content here (Profile, button, etc.)
                            Padding(
                              padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // First Row: Profile Picture and Influencer Details
                                  Row(
                                    children: [
                                      // Profile Picture
                                      Container(
                                        width: (MediaQuery.of(context).size.width * 0.80) / 4.3,  // 90% of screen width divided by 3 images
                                        height: (MediaQuery.of(context).size.width * 0.80) / 4.3,  // Fixed height for each image
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          border: Border.all(color: Colors.grey.shade400),
                                          color: Colors.grey[200],
                                          boxShadow: [
                                            if (ApproveMember.isNotEmpty && (ApproveMember['profile_image'] ?? '').isNotEmpty)
                                              BoxShadow(
                                                color: Colors.white10.withAlpha(180), // Grey shadow color with opacity
                                                spreadRadius: 1, // Spread radius of the shadow
                                                blurRadius: 6, // Blur radius of the shadow
                                                offset: Offset(0, 4), // Shadow position (x, y)
                                              ),
                                            if (ApproveMember.isNotEmpty && (ApproveMember['profile_image'] ?? '').isEmpty)
                                              BoxShadow(
                                                color: Colors.grey.withAlpha(180), // Grey shadow color with opacity
                                                spreadRadius: 1, // Spread radius of the shadow
                                                blurRadius: 3, // Blur radius of the shadow
                                                offset: Offset(0, 4), // Shadow position (x, y)
                                              ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: (ApproveMember.isNotEmpty && (ApproveMember['profile_image'] ?? '').isNotEmpty)
                                              ? Image.network(
                                            ApproveMember['profile_image'],  // Ensure the URL is encoded
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
                                                color: Colors.grey,  // Placeholder color for invalid image URLs
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
                                                var tmpname = "${ApproveMember['fname']} ${ApproveMember['lname']}";
                                                double availableWidth = tmpname.length*largeFontSize;
                                                //log('$fontSize $availableWidth ${MediaQuery.of(context).size.width * 0.38*2}');

                                                if (availableWidth > MediaQuery.of(context).size.width * 0.38*2) {
                                                  fontSize = normFontSize; // Adjust this to your needs
                                                }

                                                return Text(
                                                  tmpname,
                                                  style: TextStyle(
                                                    fontSize: fontSize, // Adjusted font size
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis, // Truncate with ellipsis if the text overflows
                                                  softWrap: false, // Prevent wrapping
                                                );
                                              },
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  ApproveMember['designation']??'',
                                                  style: TextStyle(
                                                    fontSize: smallFontSize,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                SizedBox(
                                                    width: 2,
                                                    child: Container(
                                                      width: 1,
                                                      height: smallFontSize,
                                                      color: Colors.white,
                                                    )),
                                                SizedBox(width: 5),
                                                Text(
                                                  ApproveMember['shreni']??'Not Set',
                                                  style: TextStyle(
                                                    fontSize: smallFontSize,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 1),
                                            Text(
                                              ApproveMember['description']??'',
                                              style: TextStyle(
                                                fontSize: smallFontSize - 2,
                                                color: Colors.white,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 1),
                                            Text(
                                              getHashtagNames(ApproveMember['hashtags'], hashtags),
                                              style: TextStyle(
                                                fontSize: smallFontSize - 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // List of Team Members (Selectable)
                                  Center(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.40,
                                      width: MediaQuery.of(context).size.width * 0.85,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(1),
                                        itemCount: TeamMembers.length,
                                        itemBuilder: (context, index) {
                                          final member = TeamMembers[index];
                                          bool isSelected = selectedMemberIndex == index; // Check if this member is selected
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedMemberIndex = isSelected ? -1 : index; // Toggle selection
                                                });
                                              },
                                              child: MemberCard(
                                                first_name: member['first_name']!,
                                                last_name: member['last_name']!,
                                                designation: member['designation']??"Not Set",
                                                description: member['description']??"Not Set",
                                                profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                    ? member['profile_image']!
                                                    : '',
                                                isSelected: isSelected,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Spacer to push the button to the bottom
                                  Expanded(child: SizedBox()),

                                  // Second Row: Approval Button
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 0), // 10px margin from bottom
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center, // Align button to the center
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
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
                                            onPressed: () async {
                                              // Handle the approval logic here
                                              //log('Selected Member Index: $selectedMemberIndex');
                                              if (selectedMemberIndex == -1) {
                                                // Show an error dialog if no member is selected
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text('Error'),
                                                      content: Text('Please choose a member before proceeding.'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop(); // Close the dialog
                                                          },
                                                          child: Text('OK'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                // Reset state if a member is selected
                                                bool Status = await showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: Text('Action Required'),
                                                    content: Text('Add ${TeamMembers[selectedMemberIndex]['first_name']} ${TeamMembers[selectedMemberIndex]['last_name']} as the manager, or choose a Gatanayak from their Gatanayak group.'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            assign = false;
                                                            fetchGatanayak(TeamMembers[selectedMemberIndex]['id']);
                                                            assignGatanayak = true;
                                                          });

                                                          Navigator.of(context).pop(false);  // Close dialog when choosing Gatanayak
                                                        },
                                                        child: Text('Choose Gatanayak'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          if (selectedMemberIndex > -1) {
                                                            try {
                                                              // Log the IDs for debugging purposes
                                                              //log(ApproveMember['id']);
                                                              //log(TeamMembers[selectedMemberIndex]['id']);

                                                              await apiService.approveGanyavyakthi(ApproveMember['id'], TeamMembers[selectedMemberIndex]['id']);

                                                              // Fetch unapproved profiles again
                                                              await getUnapprovedProfile();

                                                              // Reset the assign state
                                                              setState(() {
                                                                assign = false;
                                                              });

                                                              // Close the dialog with a successful result
                                                              Navigator.of(context).pop(true);
                                                            } catch (e) {
                                                              // Error handling for API failure
                                                              log('Error during approval: $e');
                                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                content: Text('An error occurred. Please try again later.'),
                                                              ));
                                                            }
                                                          }
                                                        },
                                                        child: Text('Approve and Assign'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop(false);  // Close dialog when clicking Close
                                                        },
                                                        child: Text('Close'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.all(10),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Approve and Assign',
                                                    style: TextStyle(
                                                      fontSize: largeFontSize,
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
                                  ),
                                  //assign cancel button
                                  TextButton(
                                    onPressed: () async {
                                      setState((){
                                        assign = false;
                                        selectedMemberIndex = -1;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(1),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center, // Center align the row content
                                            children: [
                                              // Text and Icon Row
                                              Text(
                                                'Cancel', // The cancel text
                                                style: TextStyle(
                                                  fontSize: smallFontSize,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8), // A small gap between the text and the icon
                                              Icon(
                                                Icons.cancel, // Cancel icon
                                                color: Colors.white, // Set the icon color to white
                                                size: smallFontSize, // You can adjust the size of the icon here
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Circular "L" at the top right
                            Positioned(
                              top: 15,
                              right: 15,
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
                                    ApproveMember['soochi']??'',  // The letter inside the circle
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
                              top: 15,
                              right: 32,
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
                                    ApproveMember['interaction_level']??'',  // The letter inside the circle
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
                        ),
                      ),
                    ),
                  ),
                ),
              if(assignGatanayak)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withAlpha(180),
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.65,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Color.fromRGBO(60, 170, 145, 1.0),
                              Color.fromRGBO(2, 40, 60, 1),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Main content here (Profile, button, etc.)
                            Padding(
                              padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // First Row: Profile Picture and Influencer Details
                                  Row(
                                    children: [
                                      // Profile Picture
                                      Container(
                                        width: (MediaQuery.of(context).size.width * 0.80) / 4.3,  // 90% of screen width divided by 3 images
                                        height: (MediaQuery.of(context).size.width * 0.80) / 4.3,  // Fixed height for each image
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          border: Border.all(color: Colors.grey.shade400),
                                          color: Colors.grey[200],
                                          boxShadow: [
                                            if (ApproveMember.isNotEmpty && (ApproveMember['profile_image'] ?? '').isNotEmpty)
                                              BoxShadow(
                                                color: Colors.white10.withAlpha(180), // Grey shadow color with opacity
                                                spreadRadius: 1, // Spread radius of the shadow
                                                blurRadius: 6, // Blur radius of the shadow
                                                offset: Offset(0, 4), // Shadow position (x, y)
                                              ),
                                            if (ApproveMember.isNotEmpty && (ApproveMember['profile_image'] ?? '').isEmpty)
                                              BoxShadow(
                                                color: Colors.grey.withAlpha(180), // Grey shadow color with opacity
                                                spreadRadius: 1, // Spread radius of the shadow
                                                blurRadius: 3, // Blur radius of the shadow
                                                offset: Offset(0, 4), // Shadow position (x, y)
                                              ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: (ApproveMember.isNotEmpty && (ApproveMember['profile_image'] ?? '').isNotEmpty)
                                              ? Image.network(
                                            ApproveMember['profile_image'],  // Ensure the URL is encoded
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
                                                color: Colors.grey,  // Placeholder color for invalid image URLs
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
                                                var tmpname = "${ApproveMember['fname']} ${ApproveMember['lname']}"??'';
                                                double availableWidth = tmpname.length*largeFontSize;
                                                //log('$fontSize $availableWidth ${MediaQuery.of(context).size.width * 0.38*2}');

                                                if (availableWidth > MediaQuery.of(context).size.width * 0.38*2) {
                                                  fontSize = normFontSize; // Adjust this to your needs
                                                }

                                                return Text(
                                                  tmpname,
                                                  style: TextStyle(
                                                    fontSize: fontSize, // Adjusted font size
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis, // Truncate with ellipsis if the text overflows
                                                  softWrap: false, // Prevent wrapping
                                                );
                                              },
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  ApproveMember['designation']??'',
                                                  style: TextStyle(
                                                    fontSize: smallFontSize,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                SizedBox(
                                                    width: 2,
                                                    child: Container(
                                                      width: 1,
                                                      height: smallFontSize,
                                                      color: Colors.white,
                                                    )),
                                                SizedBox(width: 5),
                                                Text(
                                                  'shreni',
                                                  style: TextStyle(
                                                    fontSize: smallFontSize,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 1),
                                            Text(
                                              ApproveMember['description']??'',
                                              style: TextStyle(
                                                fontSize: smallFontSize - 2,
                                                color: Colors.white,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 1),
                                            Text(
                                              getHashtagNames(ApproveMember['hashtags'], hashtags),
                                              style: TextStyle(
                                                fontSize: smallFontSize - 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  // List of Team Members (Selectable)
                                  Center(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.40,
                                      width: MediaQuery.of(context).size.width * 0.85,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(1),
                                        itemCount: Gatanayaks.length,
                                        itemBuilder: (context, index) {
                                          final member = Gatanayaks[index];
                                          bool isSelected = selectedMemberIndex == index; // Check if this member is selected
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedMemberIndex = isSelected ? -1 : index; // Toggle selection
                                                });
                                              },
                                              child: MemberCard(
                                                first_name: member['first_name']!,
                                                last_name: member['last_name']!,
                                                designation: member['designation']!,
                                                description: member['description']??"Not Set",
                                                profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                    ? member['profile_image']!
                                                    : '',
                                                isSelected: isSelected,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Spacer to push the button to the bottom
                                  Expanded(child: SizedBox()),
                                  // Second Row: Approval Button
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 0), // 10px margin from bottom
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center, // Align button to the center
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
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
                                            onPressed: () async {
                                              // Handle the approval logic here
                                              //log('Selected Member Index: $selectedMemberIndex');
                                              bool Status = await showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text('Confirmation!'),
                                                  content: Text('Add ${Gatanayaks[selectedMemberIndex]['first_name']} ${Gatanayaks[selectedMemberIndex]['last_name']} as the manager.'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () async {
                                                        if (selectedMemberIndex > -1) {
                                                          try {
                                                            // Log the IDs for debugging purposes
                                                            //log(ApproveMember['id']);
                                                            //log(Gatanayaks[selectedMemberIndex]['id']);

                                                            // API call to approve the member
                                                            await apiService.approveGanyavyakthi(ApproveMember['id'], Gatanayaks[selectedMemberIndex]['id']);

                                                            // Fetch unapproved profiles again
                                                            await getUnapprovedProfile();

                                                            // Reset the assign state
                                                            setState(() {
                                                              assignGatanayak = false;
                                                            });

                                                            // Close the dialog with a successful result
                                                            Navigator.of(context).pop(true);
                                                          } catch (e) {
                                                            // Error handling for API failure
                                                            log('Error during approval: $e');
                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                              content: Text('An error occurred. Please try again later.'),
                                                            ));
                                                          }
                                                        }
                                                      },
                                                      child: Text('Approve and Assign'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop(false);  // Close dialog when clicking Close
                                                      },
                                                      child: Text('Close'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.all(10),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Select Gatanayak',
                                                    style: TextStyle(
                                                      fontSize: largeFontSize,
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
                                  ),
                                  //assign cancel button
                                  TextButton(
                                    onPressed: () async {
                                      setState((){
                                        assignGatanayak = false;
                                        selectedMemberIndex = -1;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(1),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center, // Center align the row content
                                            children: [
                                              // Text and Icon Row
                                              Text(
                                                'Cancel', // The cancel text
                                                style: TextStyle(
                                                  fontSize: smallFontSize,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8), // A small gap between the text and the icon
                                              Icon(
                                                Icons.cancel, // Cancel icon
                                                color: Colors.white, // Set the icon color to white
                                                size: smallFontSize, // You can adjust the size of the icon here
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Circular "L" at the top right
                            Positioned(
                              top: 15,
                              right: 15,
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
                                    ApproveMember['soochi']??'',  // The letter inside the circle
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
                              top: 15,
                              right: 32,
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
                                    ApproveMember['interaction_level']??'',  // The letter inside the circle
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
                        ),
                      ),
                    ),
                  ),
                ),
              //search page
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
                            hintText: 'Search Influencer',
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
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withAlpha(180), // Semi-transparent overlay
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

          // Custom Bottom Navigation Bar with padding around it
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16,top: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(10, 205, 165, 1.0),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBottomNavItem(
                      label: "Influencers",
                      iconPath: 'assets/icon/add influencer.png',  // Use the PNG file path
                      isActive: _selectedIndex == 0,
                      onPressed: () => _onNavItemTapped(0),
                    ),
                    _buildBottomNavItem(
                      label: "Team",
                      iconPath: 'assets/icon/team.png',  // Use the PNG file path
                      isActive: _selectedIndex == 1,
                      onPressed: () => _onNavItemTapped(1),
                    ),
                    if(apiService.lvl>2)
                      _buildBottomNavItem(
                        label: "Events",
                        iconPath: 'assets/icon/meeting.png',  // Use the PNG file path
                        isActive: _selectedIndex == 2,
                        onPressed: () => _onNavItemTapped(2),
                      ),
                    if(apiService.lvl>2)
                      _buildBottomNavItem(
                        label: "Report",
                        iconPath: 'assets/icon/report.png',  // Use the PNG file path
                        isActive: _selectedIndex == 3,
                        onPressed: () => _onNavItemTapped(3),
                      ),
                    if(apiService.lvl<=2)
                      _buildBottomNavItem(
                        label: "Profile",
                        iconPath: 'assets/icon/user.png',  // Use the PNG file path
                        isActive: _selectedIndex == 5,
                        onPressed: () => _onNavItemTapped(5),
                      ),
                    /*_buildBottomNavItem(
                  label: "API",
                  iconPath: 'assets/icon/report.png',  // Use the PNG file path
                  isActive: _selectedIndex == 4,
                  onPressed: () => _onNavItemTapped(4),
                ),*/
                  ],
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          // If searching, do not show the exit dialog
          if (isSearching) {
            final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

            if (isKeyboardOpen) {
              FocusScope.of(context).unfocus();
              return false;
            } else {
              setState(() {
                infSearched = [];
                _searchController.text = '';
                isSearching = false;
              });
              return false; // Intercept back action
            }
          } else if (assign) {
            setState(() {
              assign = false;
            });
            return false;
          } else if (assignGatanayak) {
            setState(() {
              assignGatanayak = false;
              assign = true;
            });
            return false;
          }


          // Show the dialog to confirm exit
          bool exit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Exit App'),
              content: Text('Are you sure you want to exit?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // No, don't exit
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Yes, exit
                  },
                  child: Text('Yes'),
                ),
              ],
            ),
          );

          // Exit the app if 'Yes' is pressed
          if (exit == true) {
            SystemNavigator.pop();  // Close the app
          }

          return exit ?? false; // Return false if exit is null
        }
    );
  }


  Widget _buildBottomNavItem({
    required String label,
    required String iconPath,  // Change IconData to iconPath (a string representing the PNG path)
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Container(
                width: 45, // Inner container size
                height: 45, // Inner container size
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color.fromRGBO(5, 50, 70, 1.0)
                      : Colors.white, // Optional: Background color of the inner container
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    color: isActive ? Colors.white : const Color.fromRGBO(5, 50, 70, 1.0),
                    fit: BoxFit.contain, // Ensures image scales to fit within inner container
                    width: 30, // Image width
                    height: 30, // Image height
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color.fromRGBO(5, 50, 70, 1.0),
              fontSize: MediaQuery.of(context).size.width * 0.041 - 4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

}
class MemberCard extends StatelessWidget {
  final String first_name;
  final String last_name;
  final String designation;
  final String description;
  final String profileImage;
  final bool isSelected;

  const MemberCard({
    super.key,

    required this.first_name,
    required this.last_name,
    required this.designation,
    required this.profileImage,
    required this.isSelected,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.green[200] : Colors.white,
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(0), // Container padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[200] : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16,top: 16,left: 8,right: 8), // Add padding to the content
          child: Row(
            children: [
              // Profile Picture (placeholder)
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
                        color: Color.fromRGBO(5, 50, 70, 1.0).withAlpha(180), // Grey shadow color with opacity
                        spreadRadius: 1, // Spread radius of the shadow
                        blurRadius: 7, // Blur radius of the shadow
                        offset: Offset(0, 4), // Shadow position (x, y)
                      ),
                    if(profileImage.isEmpty)
                      BoxShadow(
                        color: Colors.grey.withAlpha(180), // Grey shadow color with opacity
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
                    Text(
                      '$first_name $last_name', // Dynamic name
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

class SearchCard extends StatelessWidget {
  final String first_name;
  final String last_name;
  final String profileImage;
  final bool isSelected;

  const SearchCard({
    super.key,

    required this.first_name,
    required this.last_name,
    required this.profileImage,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.green[200] : Colors.white,
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(0), // Container padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[200] : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16,top: 16,left: 8,right: 8), // Add padding to the content
          child: Row(
            children: [
              // Profile Picture (placeholder)
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.08,
                backgroundColor: Colors.grey[200],
                //backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
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
                      '$first_name $last_name', // Dynamic name
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
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


