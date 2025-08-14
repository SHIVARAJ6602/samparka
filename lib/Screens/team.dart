import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samparka/Screens/meeting.dart';
import 'package:samparka/Screens/my_team.dart';
import 'package:samparka/Screens/user_profile_page.dart';
import 'package:samparka/Screens/register_user.dart';
import 'package:samparka/Screens/profile_page.dart';
import 'package:samparka/widgets/loading_indicator.dart';
import '../widgets/menu_drawer.dart';
import 'gen_report.dart';
import 'help.dart';
import 'home.dart';
import 'api_test.dart'; //TaskListScreen()
import 'my_mjsp.dart';
import 'notifications.dart';
import 'package:samparka/Service/api_service.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  TeamPageState createState() => TeamPageState();
}

class TeamPageState extends State<TeamPage> {
  // This keeps track of the selected index for the bottom navigation
  int _selectedIndex = 1;
  final apiService = ApiService();
  final FocusNode _focusNode = FocusNode(); // search focus node
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> members = [];
  List<dynamic> mjMembers = []; // mahanagar and Jilla
  List<dynamic> gatanayaks = [];
  List<dynamic> membersSearched = [];
  List<dynamic> supervisor = [];
  List<dynamic> lead = [];
  late List<dynamic> result = [];

  bool _isLoadingSupervisors = true;
  bool _isLoadingMJMembers = true;
  bool _isLoadingMembers = true;
  bool _isLoadingGatanayaks = true;
  bool _isLoadingLead = true;
  bool _isLoadingSearchedMembers = false;

  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    fetchSupervisor();
    if (apiService.lvl > 3) {
      fetchMJMembers();
    }
    if (apiService.lvl > 1) {
      fetchMembers();
      fetchGatanayak(apiService.UserId);
    }
    if (apiService.lvl == 1) {
      fetchLead();
    }
  }

  // Method to handle bottom navigation item tap
  void _onNavItemTapped(int index) {
    if (index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ApiScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GenReportPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MeetingPage()),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InfluencersPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> fetchMembers() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMembers = true;
    });
    try {
      result = await apiService.myTeam(0, 100);
      if (!mounted) return;
      setState(() {
        members = result;
      });
    } catch (e) {
      log("Error fetching members: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingMembers = false;
      });
    }
  }

  Future<void> fetchMJMembers() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMJMembers = true;
    });
    try {
      result = await apiService.myMJMembers(0, 100);
      if (!mounted) return;
      setState(() {
        mjMembers = result;
      });
    } catch (e) {
      log("Error fetching MJ members: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingMJMembers = false;
      });
    }
  }

  Future<void> fetchSupervisor() async {
    if (!mounted) return;
    setState(() {
      _isLoadingSupervisors = true;
    });
    try {
      result = await apiService.mySupervisor();
      if (!mounted) return;
      setState(() {
        supervisor = result;
      });
    } catch (e) {
      log("Error fetching supervisor: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingSupervisors = false;
      });
    }
  }

  Future<void> fetchGatanayak(String krID) async {
    if (!mounted) return;
    setState(() {
      _isLoadingGatanayaks = true;
    });
    try {
      result = await apiService.getGatanayak(krID);
      if (!mounted) return;
      setState(() {
        gatanayaks = result;
      });
    } catch (e) {
      log("Error fetching Gatanayaks: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingGatanayaks = false;
      });
    }
  }

  Future<void> fetchLead() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLead = true;
    });
    try {
      result = await apiService.myLead();
      if (!mounted) return;
      setState(() {
        lead = result;
      });
    } catch (e) {
      log("Error fetching lead: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingLead = false;
      });
    }
  }

  Future<void> search(String str) async {
    if (str.isEmpty) {
      setState(() {
        membersSearched = [];
        _isLoadingSearchedMembers = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoadingSearchedMembers = true;
      membersSearched = [];
    });
    try {
      var mem = await apiService.searchKR(str);
      if (!mounted) return;
      if (mem is List) {
        setState(() {
          membersSearched = mem;
        });
      } else {
        setState(() {
          membersSearched = [];
        });
      }
    } catch (e) {
      log("Error searching members: $e");
      if (!mounted) return;
      setState(() {
        membersSearched = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingSearchedMembers = false;
      });
    }
  }

  Widget _buildEmptySection(String message, double fontSize) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize + 4; //20
    double smallFontSize = normFontSize - 2; //14

    return PopScope(
        canPop: !isSearching,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) {
            return;
          }
          if (isSearching) {
            setState(() {
              isSearching = false;
              membersSearched = [];
              _searchController.clear();
              FocusScope.of(context).unfocus(); 
            });
          }
        },
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
                  )
                : null,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            elevation: 0,
            title: Text('Samparka',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.bug_report,
                    color: Color.fromRGBO(5, 50, 70, 1.0)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HelpPage()), // Your help/feedback screen
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Color.fromRGBO(5, 50, 70, 1.0)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationsPage()),
                  );
                },
              ),
            ],
          ),
          drawer: MenuDrawer(apiService: apiService),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isSearching)
                            Column(
                              children: [
                                TextField(
                                  controller: _searchController,
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color.fromRGBO(
                                        217, 217, 217, 1.0),
                                    hintText: 'Search Member',
                                    hintStyle: TextStyle(
                                      fontSize: normFontSize,
                                      fontWeight: FontWeight.normal,
                                      color:
                                          Color.fromRGBO(128, 128, 128, 1.0),
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
                                              Color.fromRGBO(
                                                  60, 245, 200, 1.0),
                                              Color.fromRGBO(2, 40, 60, 1),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(Icons.search,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  onChanged: (text) {
                                    search(text);
                                  },
                                  onTap: () {
                                    // isSearching = true; // Already true if this is visible
                                  },
                                ),
                                const SizedBox(height: 22),
                              ],
                            ),
                          if (!isSearching)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isSearching = true;
                                  _focusNode.requestFocus();
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: const Color.fromRGBO(
                                    217, 217, 217, 1.0),
                                minimumSize: Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '     Search Member',
                                      style: TextStyle(
                                        fontSize: normFontSize,
                                        fontWeight: FontWeight.normal,
                                        color: Color.fromRGBO(
                                            128, 128, 128, 1.0),
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
                                      child: const Icon(Icons.search,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (!isSearching)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // My Supervisor / Pramukh Section
                                AutoSizeText(
                                  _isLoadingSupervisors
                                      ? 'My Pramukh'
                                      : supervisor.isEmpty
                                          ? 'My Pramukh'
                                          : (supervisor[0]['designation'] ??
                                              'My Pramukh'),
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: largeFontSize * 2,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        const Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                  minFontSize: largeFontSize.floorToDouble(),
                                  stepGranularity: 1.0,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: _isLoadingSupervisors || supervisor.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color.fromRGBO(60, 170, 145, 1.0),
                                        Color.fromRGBO(2, 40, 60, 1),
                                      ],
                                    ),
                                  ),
                                  child: _isLoadingSupervisors
                                      ? LoadingIndicator()
                                      : supervisor.isEmpty
                                          ? _buildEmptySection(
                                              'No Pramukh Assigned',
                                              largeFontSize)
                                          : Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: (MediaQuery.of(context).size.width *0.80) /5,
                                                          height: (MediaQuery.of(context).size.width *0.80) /5,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(50),
                                                            border: Border.all(color: Colors.grey.shade400),
                                                            color: Colors.grey[200],
                                                            boxShadow: [
                                                              if (supervisor.isNotEmpty && (supervisor[0]['profile_image'] ?? '').isNotEmpty)
                                                                BoxShadow(
                                                                  color: Color.fromRGBO(2, 40, 60, 1).withAlpha(230),
                                                                  spreadRadius: 1,
                                                                  blurRadius: 6,
                                                                  offset: Offset(0, 4),
                                                                ),
                                                              if (supervisor.isNotEmpty && (supervisor[0]['profile_image'] ?? '').isEmpty)
                                                                BoxShadow(
                                                                  color: Colors.grey.withAlpha(128),
                                                                  spreadRadius: 1,
                                                                  blurRadius: 3,
                                                                  offset: Offset(0, 4),
                                                                ),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(50),
                                                            child: (supervisor.isNotEmpty && (supervisor[0]['profile_image'] ?? '').isNotEmpty)
                                                                ? Image.network(
                                                                    supervisor[0]['profile_image'],
                                                                    fit: BoxFit.cover,
                                                                    loadingBuilder: (context, child, loadingProgress) {
                                                                      if (loadingProgress == null) return child;
                                                                      return Center( child: CircularProgressIndicator( value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null, ), );
                                                                    },
                                                                    errorBuilder: (context, error, stackTrace) {
                                                                      return Container( color: Colors.red, child: Center( child: Icon(Icons.error, color: Colors.white), ), );
                                                                    },
                                                                  )
                                                                : Icon( Icons.person, color: Colors.white, size: MediaQuery.of(context).size.width * 0.14, ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 16),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                "${supervisor[0]['first_name']!} ${supervisor[0]['last_name']}",
                                                                style: TextStyle( fontSize: largeFontSize + 6, fontWeight: FontWeight.bold, color: Colors.white, ),
                                                              ),
                                                              Text(
                                                                supervisor[0]['designation'] ?? '',
                                                                style: TextStyle( fontSize: smallFontSize, color: Colors.white, ),
                                                              ),
                                                              SizedBox(height: 1),
                                                              Text(
                                                                supervisor[0]['district'] ?? "",
                                                                style: TextStyle( fontSize: smallFontSize - 2, color: Colors.white, ),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                            ),
                                ),

                                // My MJ SP's Section
                                if (apiService.lvl > 4)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      AutoSizeText(
                                        'Mahanagar and Jilla SP\'s',
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: largeFontSize * 2,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromRGBO(
                                              5, 50, 70, 1.0),
                                        ),
                                        minFontSize:
                                            largeFontSize.floorToDouble(),
                                        stepGranularity: 1.0,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: _isLoadingMJMembers || mjMembers.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color.fromRGBO(
                                                  60, 170, 145, 1.0),
                                              Color.fromRGBO(2, 40, 60, 1),
                                            ],
                                          ),
                                        ),
                                        child: _isLoadingMJMembers
                                            ? LoadingIndicator()
                                            : mjMembers.isEmpty
                                                ? _buildEmptySection(
                                                    'No Members Assigned',
                                                    largeFontSize)
                                                : Column(
                                                    children: [
                                                      ...List.generate(
                                                        (mjMembers.length < 4)
                                                            ? mjMembers.length
                                                            : 3,
                                                        (index) {
                                                          final member =
                                                              mjMembers[index];
                                                          return Padding(
                                                            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                                            child: MemberCard(
                                                              id: member['id']!,
                                                              first_name: member['first_name']!,
                                                              last_name: member['last_name']!,
                                                              designation: member['designation'] ?? "Not Set",
                                                              profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                                  ? member['profile_image']!
                                                                  : '',
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      if (mjMembers.isNotEmpty)
                                                        TextButton(
                                                          onPressed: () async {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => const MyMJSPPage(type: 'ShreniPramukh')),
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

                                // My Shreni Pramukh Section (Lead for Gatanayak)
                                if (apiService.lvl < 2)
                                   Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      AutoSizeText(
                                        'Shreni Pramukh',
                                        maxLines: 1,
                                        style: TextStyle(fontSize: largeFontSize * 2, fontWeight: FontWeight.bold, color: const Color.fromRGBO(5, 50, 70, 1.0),),
                                        minFontSize: largeFontSize.floorToDouble(),
                                        stepGranularity: 1.0,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                           borderRadius: _isLoadingLead || lead.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
                                          gradient: const LinearGradient( colors: [ Color.fromRGBO(60, 170, 145, 1.0), Color.fromRGBO(2, 40, 60, 1), ], begin: Alignment.topCenter, end: Alignment.bottomCenter, ),
                                        ),
                                        child: _isLoadingLead
                                            ? LoadingIndicator()
                                            : lead.isEmpty
                                                ? _buildEmptySection('No Shreni Pramukh Assigned', largeFontSize)
                                                : Container( // Content for when lead is not empty
                                                    padding: const EdgeInsets.all(16),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: (MediaQuery.of(context).size.width * 0.80) / 5,
                                                              height: (MediaQuery.of(context).size.width * 0.80) / 5,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(50),
                                                                border: Border.all(color: Colors.grey.shade400),
                                                                color: Colors.grey[200],
                                                                boxShadow: [
                                                                  if (lead.isNotEmpty && (lead[0]['profile_image'] ?? '').isNotEmpty)
                                                                    BoxShadow( color: Colors.white10..withAlpha(128), spreadRadius: 1, blurRadius: 6, offset: Offset(0, 4), ),
                                                                  if (lead.isNotEmpty && (lead[0]['profile_image'] ?? '').isEmpty)
                                                                    BoxShadow( color: Colors.grey.withAlpha(128), spreadRadius: 1, blurRadius: 3, offset: Offset(0, 4), ),
                                                                ],
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius: BorderRadius.circular(50),
                                                                child: (lead.isNotEmpty && (lead[0]['profile_image'] ?? '').isNotEmpty)
                                                                    ? Image.network(
                                                                        lead[0]['profile_image'],
                                                                        fit: BoxFit.cover,
                                                                        loadingBuilder: (context, child, loadingProgress) {
                                                                          if (loadingProgress == null) return child;
                                                                          return Center( child: CircularProgressIndicator( value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null, ), );
                                                                        },
                                                                        errorBuilder: (context, error, stackTrace) { return Container( color: Colors.red, child: Center( child: Icon(Icons.error, color: Colors.white), ), ); },
                                                                      )
                                                                    : Icon( Icons.person, color: Colors.white, size: MediaQuery.of(context).size.width * 0.14, ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 16),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text( "${lead[0]['first_name']} ${lead[0]['last_name']}", style: TextStyle( fontSize: largeFontSize + 6, fontWeight: FontWeight.bold, color: Colors.white, ), ),
                                                                  Text( lead[0]['designation'] ?? 'Not Set', style: TextStyle( fontSize: smallFontSize, color: Colors.white, ), ),
                                                                  SizedBox(height: 1),
                                                                  Text( lead[0]['district'] ?? "", style: TextStyle( fontSize: smallFontSize - 2, color: Colors.white, ), maxLines: 2, overflow: TextOverflow.ellipsis, ),
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

                                // My Shreni Pramukhs (Members) Section
                                if (apiService.lvl > 2 && apiService.lvl<5)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      AutoSizeText(
                                        'Shreni Pramukhs',
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: largeFontSize * 2,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromRGBO(
                                              5, 50, 70, 1.0),
                                        ),
                                        minFontSize:
                                            largeFontSize.floorToDouble(),
                                        stepGranularity: 1.0,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 1),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: _isLoadingMembers || members.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color.fromRGBO(
                                                  60, 170, 145, 1.0),
                                              Color.fromRGBO(2, 40, 60, 1),
                                            ],
                                          ),
                                        ),
                                        child: _isLoadingMembers
                                            ? LoadingIndicator()
                                            : members.isEmpty
                                                ? _buildEmptySection(
                                                    'No Members Assigned',
                                                    largeFontSize)
                                                : Column(
                                                    children: [
                                                      ...List.generate(
                                                        (members.length < 4)
                                                            ? members.length
                                                            : 3,
                                                        (index) {
                                                          final member =
                                                              members[index];
                                                          return Padding(
                                                            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                                            child: MemberCard(
                                                              id: member['id']!,
                                                              first_name: member['first_name']!,
                                                              last_name: member['last_name']!,
                                                              designation: member['designation'] ?? "Not Set",
                                                              profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                                  ? member['profile_image']!
                                                                  : '',
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      if (members.isNotEmpty)
                                                        TextButton(
                                                          onPressed: () async {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => const MyTeamPage(type: 'ShreniPramukh')),
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

                                // My Gatanayaks Section
                                if (apiService.lvl > 1 && apiService.lvl<5)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        'Gatanayaks',
                                        style: TextStyle(
                                          fontSize: largeFontSize * 2,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromRGBO(
                                              5, 50, 70, 1.0),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: _isLoadingGatanayaks || gatanayaks.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color.fromRGBO(
                                                  60, 170, 145, 1.0),
                                              Color.fromRGBO(2, 40, 60, 1),
                                            ],
                                          ),
                                        ),
                                        child: _isLoadingGatanayaks
                                            ? LoadingIndicator()
                                            : gatanayaks.isEmpty
                                                ? _buildEmptySection(
                                                    'No Gatanayak Assigned',
                                                    largeFontSize)
                                                : Column(
                                                    children: [
                                                      ...List.generate(
                                                        (gatanayaks.length < 4)
                                                            ? gatanayaks.length
                                                            : 3,
                                                        (index) {
                                                          final member =
                                                              gatanayaks[index];
                                                          return Padding(
                                                            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                                                            child: MemberCard(
                                                              id: member['id']!,
                                                              first_name: member['first_name']!,
                                                              last_name: member['last_name']!,
                                                              designation: member['designation'] ?? "Not Set",
                                                              profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                                  ? member['profile_image']!
                                                                  : '',
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      if (gatanayaks.isNotEmpty)
                                                        TextButton(
                                                          onPressed: () async {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => const MyTeamPage(type: 'Gatanayaks')),
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
                                if (apiService.lvl > 2)
                                  Column(
                                    children: [
                                      const SizedBox(height: 20),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Color.fromRGBO(2, 40, 60, 1),
                                              Color.fromRGBO(
                                                  60, 170, 145, 1.0)
                                            ],
                                          ),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      RegisterUserPage()),
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.only(
                                                left: 0,
                                                right: 0,
                                                bottom: 10,
                                                top: 10),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Add New Member',
                                              style: TextStyle(
                                                fontSize: largeFontSize,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          // Search page content
                          if (isSearching)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: _isLoadingSearchedMembers || membersSearched.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.fromRGBO(60, 170, 145, 1.0),
                                    Color.fromRGBO(2, 40, 60, 1),
                                  ],
                                ),
                              ),
                              child: _isLoadingSearchedMembers
                                  ? LoadingIndicator()
                                  : membersSearched.isEmpty
                                      ? _buildEmptySection(
                                          'No Karyakartha Found',
                                          normFontSize + 2)
                                      : Column(
                                          children: List.generate(
                                            membersSearched.length, // Show all searched members
                                            (index) {
                                              final member =
                                                  membersSearched[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(left: 8, right: 8, top: 20, bottom: 10),
                                                child: MemberCard(
                                                  id: member['id'] ?? '',
                                                  first_name: member['first_name'] ?? '',
                                                  last_name: member['last_name'] ?? '',
                                                  designation: member['designation'] ?? '',
                                                  profileImage: member['profile_image'] != null && member['profile_image']!.isNotEmpty
                                                      ? member['profile_image']!
                                                      : '',
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 16, top: 1),
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
                      iconPath: 'assets/icon/add influencer.png',
                      isActive: _selectedIndex == 0,
                      onPressed: () => _onNavItemTapped(0),
                    ),
                    _buildBottomNavItem(
                      label: "Team",
                      iconPath: 'assets/icon/team.png',
                      isActive: _selectedIndex == 1,
                      onPressed: () => _onNavItemTapped(1),
                    ),
                    if (apiService.lvl > 2)
                      _buildBottomNavItem(
                        label: "Events",
                        iconPath: 'assets/icon/meeting.png',
                        isActive: _selectedIndex == 2,
                        onPressed: () => _onNavItemTapped(2),
                      ),
                    if (apiService.lvl > 2)
                      _buildBottomNavItem(
                        label: "Report",
                        iconPath: 'assets/icon/report.png',
                        isActive: _selectedIndex == 3,
                        onPressed: () => _onNavItemTapped(3),
                      ),
                    if (apiService.lvl <= 2)
                      _buildBottomNavItem(
                        label: "Profile",
                        iconPath: 'assets/icon/user.png',
                        isActive: _selectedIndex == 5,
                        onPressed: () => _onNavItemTapped(5),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        );
  }

  Widget _buildBottomNavItem({
    required String label,
    required String iconPath,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    double smallFontSize =
        MediaQuery.of(context).size.width * 0.041 - 2; //14
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
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color.fromRGBO(5, 50, 70, 1.0)
                      : Colors.white,
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    color: isActive
                        ? Colors.white
                        : const Color.fromRGBO(5, 50, 70, 1.0),
                    fit: BoxFit.contain,
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : const Color.fromRGBO(5, 50, 70, 1.0),
              fontSize: smallFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final String id;
  final String first_name;
  final String last_name;
  final String designation;
  final String profileImage;

  const MemberCard({
    super.key,
    required this.id,
    required this.first_name,
    required this.last_name,
    required this.designation,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    double largeFontSize = MediaQuery.of(context).size.width * 0.041 + 4; //20
    double smallFontSize = MediaQuery.of(context).size.width * 0.041 - 2; //14
    return Container(
      padding: const EdgeInsets.all(0),
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
            MaterialPageRoute(builder: (context) => UserProfilePage(id)),
          );
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )),
          padding: WidgetStateProperty.all(EdgeInsets.zero), // Remove default padding
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding to the content
          child: Row(
            children: [
              Container(
                width: (MediaQuery.of(context).size.width * 0.80) / 5,
                height: (MediaQuery.of(context).size.width * 0.80) / 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.grey[200],
                  boxShadow: [
                    if (profileImage.isNotEmpty)
                      BoxShadow(
                        color:
                            Color.fromRGBO(5, 50, 70, 1.0).withAlpha(128),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: Offset(0, 4),
                      ),
                    if (profileImage.isEmpty)
                      BoxShadow(
                        color: Colors.grey.withAlpha(128),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 4),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: (profileImage.isNotEmpty)
                      ? Image.network(
                          profileImage,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white,
                              child: Center(
                                child: Icon(Icons.error,
                                    color: Colors.grey[400],
                                    size: MediaQuery.of(context).size.width *
                                        0.075),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$first_name $last_name',
                      style: TextStyle(
                        fontSize: largeFontSize + 6,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                    Text(
                      designation,
                      style: TextStyle(
                        fontSize: smallFontSize,
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
