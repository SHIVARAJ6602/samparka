import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samparka/Screens/migrate_influencer.dart';
import 'package:samparka/Screens/user_profile_page.dart';
import '../Service/api_service.dart';
import '../widgets/influencer_card.dart';
import '../widgets/member_card.dart';
import 'influencer_profile.dart';
import 'migrate_influencer_for_migrate_user.dart';

class MigrateUserPage extends StatefulWidget {
  final String userId;
  final int lvl; // 1–5

  const MigrateUserPage({required this.userId, required this.lvl, super.key});

  @override
  MigrateUserPageState createState() => MigrateUserPageState();
}

class MigrateUserPageState extends State<MigrateUserPage> {
  final apiService = ApiService();

  bool loading = true;

  List<dynamic> myInfluencers = [];
  List<dynamic> myShreniPramukhs = [];
  List<dynamic> myGatanayaks = [];
  List<dynamic> shreniPramukhs = [];
  List<dynamic> mjSP = [];
  List<dynamic> gatanayaks = [];
  dynamic myProfile = {};

  Map<String, List<dynamic>> mjSPInfluencers = {};
  Map<String, List<dynamic>> mjSPShreniPramukhs = {};
  Map<String, List<dynamic>> mjSPGatanayaks = {};
  Map<String, List<dynamic>> shreniPramukhInfluencers = {};
  Map<String, List<dynamic>> shreniPramukhGatanayaks = {};
  Map<String, List<dynamic>> gatanayakInfluencers = {};
  List<String> selectedInfluencerIds = [];
  Set<String> expandedLists = {};
  List<dynamic> hashtags = [];
  late List<dynamic> result;
  List<dynamic> members = [];

  String? selectedGroupId;
  String? selectedKaryakarthaId;
  String? selectedShreniPramukhId;
  String? selectedMJId;
  String? selectedGatanayakId;
  String? selectedShreniId;
  String? selectedSupervisorId;
  List<dynamic> groups = [];
  Set<dynamic> _expandedTileIds = {};
  Set<dynamic> _expandedMjIds = {};
  Set<dynamic> _expandedSpIds = {};
  bool isLoading = false;
  bool migrateInfluencer = false;



  String? selectedShreni;
  List<String> shrenis = ["Administration","Art and Award Winners","Economic","Healthcare","Intellectuals","Law and Judiciary","Religious","Science and Research","Social Leaders and Organizations","Sports"];


  @override
  void initState() {
    super.initState();
    _loadAllData();
    fetchGroups();
    print('inf count: ${apiService.getInfluencerCount(apiService.UserId)}');
  }

  List<dynamic> formatInfluencers(List<dynamic> influencers) {
    for (var inf in influencers) {
      if (inf['soochi'] == 'AkhilaBharthiya') inf['soochi'] = 'AB';
      else if (inf['soochi'] == 'PranthyaSampark') inf['soochi'] = 'PS';
      else if (inf['soochi'] == 'JillaSampark') inf['soochi'] = 'JS';

      if (inf['interaction_level'] == 'Sampark') inf['interaction_level'] = 'S1';
      else if (inf['interaction_level'] == 'Sahavas') inf['interaction_level'] = 'S2';
      else if (inf['interaction_level'] == 'Samarthan') inf['interaction_level'] = 'S3';
      else if (inf['interaction_level'] == 'Sahabhag') inf['interaction_level'] = 'S4';
    }
    return influencers;
  }

  Future<void> fetchMembers() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.myTeam(0, 100);
      if (result.isEmpty) {
        setState(() {
          selectedKaryakarthaId = apiService.UserId;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('No ShreniPramuhk to assign \n defualting to self:${apiService.first_name}'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
      result.add({'id': apiService.UserId,'first_name': 'self(${apiService.first_name})','last_name': ''});
      setState(() {
        //print('members $result');
        members = result;
      });
    } catch (e) {
      //print("Error fetching influencers: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to loading members")),
      );
    }
  }

  Future<int> getInfluencerCount(String krId) async {
    try {
      // Call the API and get the influencer count
      int result = await apiService.getInfluencerCount(krId);

      // Example logic: Check if result == 0
      setState(() {
        print('inf count: $result');
      });
      return result;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to get Influencer Count")),
      );
      return -1;
    }
  }

  Future<void> _loadAllData() async {
    setState(() => loading = true);

    var lvl = apiService.lvl;

    try {
      fetchHashtags();

      myProfile = await apiService.getKaryakartha(widget.userId);
      print('myProfile $myProfile');

      //myInfluencers = formatInfluencers(await fetchInfluencersForUser(widget.userId));
      myGatanayaks = await apiService.getGatanayak(widget.userId);
      //shreniPramukhGatanayaks[widget.userId] = myGatanayaks;

      for (var gk in myGatanayaks) {
        //gatanayakInfluencers[gk['id']] = formatInfluencers(await fetchInfluencersForUser(gk['id']));
      }

      if (lvl > 2) {
        myShreniPramukhs = await apiService.getShreniPramukhs(apiService.UserId);
        for (var sp in myShreniPramukhs) {
          final spId = sp['id'];
          //shreniPramukhInfluencers[spId] = formatInfluencers(await fetchInfluencersForUser(spId));
          final gatanayaks = await apiService.getGatanayak(spId);
          shreniPramukhGatanayaks[spId] = gatanayaks;

          for (var gk in gatanayaks) {
            //gatanayakInfluencers[gk['id']] = formatInfluencers(await fetchInfluencersForUser(gk['id']));
          }
        }
      }

      if (lvl > 4) {
        mjSP = await apiService.myMJMembers(0, 100);
        for (var mj in mjSP) {
          final mjId = mj['id'];
          // influencers directly under MJSP
          //mjSPInfluencers[mjId] = formatInfluencers(await fetchInfluencersForUser(mjId));
          // gatanayaks directly under MJSP
          final mjGk = await apiService.getGatanayak(mjId);
          mjSPGatanayaks[mjId] = mjGk;
          // shreni pramukh under MJSP
          final mjSPShrenis = await apiService.getShreniPramukhs(mjId);
          mjSPShreniPramukhs[mjId] = mjSPShrenis;
          //print('MJSP SP: $mjSPShreniPramukhs');

          // loop each Shreni under MJSP
          for (var sp in mjSPShrenis) {
            final spId = sp['id'];
            //shreniPramukhInfluencers[spId] = formatInfluencers(await fetchInfluencersForUser(spId));
            final spGk = await apiService.getGatanayak(spId);
            shreniPramukhGatanayaks[spId] = spGk;
            for (var gk in spGk) {
              //gatanayakInfluencers[gk['id']] = formatInfluencers(await fetchInfluencersForUser(gk['id']));
            }
          }

          // loop MJSP → Gatanayaks
          for (var gk in mjGk) {
            //gatanayakInfluencers[gk['id']] = formatInfluencers(await fetchInfluencersForUser(gk['id']));
          }
        }
      }

    } catch (e) {
      log('Error loading data: $e');
    }

    setState(() => loading = false);
  }

  Future<void> fetchGroups() async {
    try {
      final groupList = await apiService.getGroups();
      setState(() {
        groups = groupList;
        //print('fetched groups $groups');
      });
    } catch (e) {
      //print("Error fetching groups: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load groups")),
      );
    }
  }

  Future<List<dynamic>> fetchInfluencersForUser(String userId) async {
    try {
      return await apiService.getInfluencer(1, 100, userId);
    } catch (e) {
      log('Error fetching influencers for user $userId: $e');
      return [];
    }
  }

  void _toggleInfluencerSelection(String influencerId) {
    setState(() {
      selectedInfluencerIds.contains(influencerId)
          ? selectedInfluencerIds.remove(influencerId)
          : selectedInfluencerIds.add(influencerId);
    });
  }

  Future<void> fetchHashtags() async {
    try {
      result = await apiService.getHashtags();
      setState(() => hashtags = result);
    } catch (e) {
      log("Error fetching hashtags: $e");
    }
  }

  String getHashtagNames(dynamic influencerHashtagIds, dynamic allHashtags) {
    final List<int> ids = List<int>.from(influencerHashtagIds ?? []);
    final List<Map<String, dynamic>> tags = List<Map<String, dynamic>>.from(allHashtags ?? []);

    return ids.map((id) {
      final tag = tags.firstWhere((tag) => tag['id'] == id, orElse: () => {});
      final name = tag['name'];
      return name != null ? '#$name' : '';
    }).where((name) => name.isNotEmpty).join(', ');
  }

  void _migrateSelectedInfluencers(String targetUserId) async {
    if (selectedInfluencerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one influencer to migrate.")),
      );
      return;
    }

    try {
      final result = await apiService.migrateInfluencers(selectedInfluencerIds, targetUserId);
      final migrated = result['migrated'] ?? [];
      final failed = result['failed'] ?? [];

      String message = '';
      if (migrated.isNotEmpty) message += "${migrated.length} influencer(s) migrated successfully.\n";
      if (failed.isNotEmpty) {
        message += "${failed.length} failed to migrate:\n";
        for (var f in failed.take(3)) {
          message += "- ${f['id']}: ${f['reason']}\n";
        }
        if (failed.length > 3) message += "...and ${failed.length - 3} more.\n";
      }

      selectedInfluencerIds.clear();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Migration Result"),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK"))],
        ),
      );

      await _loadAllData();
    } catch (e) {
      log("Migration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Migration failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 0,
          title: Text("Migrate Karyakartha"),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        title: Text("Migrate Karyakartha"),
      ),
      body: Stack(
        children: [
          /*
          if(migrateInfluencer)
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(height: 600,),
                  ),
                  Text('Migrate inf 1'),
                  ElevatedButton(onPressed: () {
                    setState(() {
                      migrateInfluencer = false;
                    });
                  }, child: Text('disable Migrate'),
                  ),
                ],
              ),
            ),
          */
          if(!migrateInfluencer)
            SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((myGatanayaks.isNotEmpty ?? false))
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "My Gatanayaks",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...myGatanayaks.map((gk) {
                        final gkId = gk['id'];
                        final gkName = "${gk['first_name']} ${gk['last_name']}";
                        return ListTile(
                          title: _buildKaryakarthaProfile(gk, allowTap: false),
                          onTap: () => _showConfirmationDialog("${gk['first_name']} ${gk['last_name']}", gk['id'], gk, apiService.UserId, apiService.lvl,apiService.UserId),
                        );
                      }).toList(),
                    ],
                  ),

                Divider(),

                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        " My Shreni Pramukhs",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: myShreniPramukhs.map((sp) {
                        final spId = sp['id'];
                        final spName = "${sp['first_name']} ${sp['last_name']}";

                        return ExpansionTile(
                          key: ValueKey(spId), // Helps maintain state during rebuilds
                          title: _expandedTileIds.contains(spId)
                              ? Text(spName)
                              : AbsorbPointer(child: _buildKaryakarthaProfile(sp, allowTap: false)),
                          onExpansionChanged: (expanded) {
                            setState(() {
                              if (expanded) {
                                _expandedTileIds.add(spId);
                              } else {
                                _expandedTileIds.remove(spId);
                              }
                            });
                          },
                          children: [
                            ListTile(
                              title: _buildKaryakarthaProfile(sp, allowTap: false),
                              onTap: () => _showConfirmationDialog(spName, spId, sp, myProfile, apiService.lvl , myProfile),
                            ),
                            if ((shreniPramukhGatanayaks[spId]?.isNotEmpty ?? false))
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text("Gatanayaks", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                              ),
                            ...?shreniPramukhGatanayaks[spId]?.map((gk) {
                              final gkId = gk['id'];
                              final gkName = "${gk['first_name']} ${gk['last_name']}";
                              return ListTile(
                                title: _buildKaryakarthaProfile(gk, allowTap: false),
                                onTap: () => _showConfirmationDialog("${gk['first_name']} ${gk['last_name']}", gk['id'], gk, myProfile, apiService.lvl , sp),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),

                Divider(),

                if (mjSP.isNotEmpty)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "My MJ Samparka Pramukhs",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        children: mjSP.map((mj) {
                          final mjId = mj['id'];
                          final mjName = "${mj['first_name']} ${mj['last_name']}";

                          return ExpansionTile(
                            key: ValueKey("mj_$mjId"),
                            title: _expandedMjIds.contains(mjId)
                                ? Text(mjName)
                                : AbsorbPointer(child: _buildKaryakarthaProfile(mj, allowTap: false)),
                            onExpansionChanged: (expanded) {
                              setState(() {
                                if (expanded) {
                                  _expandedMjIds.add(mjId);
                                } else {
                                  _expandedMjIds.remove(mjId);
                                }
                              });
                            },
                            children: [
                              ListTile(
                                title: _buildKaryakarthaProfile(mj, allowTap: false),
                                onTap: () => _showConfirmationDialog(mjName, mjId, mj,myProfile, apiService.lvl, myProfile),
                              ),

                              // Gatanayaks under MJ
                              ...?mjSPGatanayaks[mjId]?.map((gk) {
                                final gkName = "${gk['first_name']} ${gk['last_name']}";
                                return ListTile(
                                  title: _buildKaryakarthaProfile(gk, allowTap: false),
                                  onTap: () => _showConfirmationDialog(gkName, gk['id'], gk,mj,mj['level'],mj),
                                );
                              }),

                              // Shreni Pramukhs under MJSP
                              ...?mjSPShreniPramukhs[mjId]?.map((sp) {
                                final spId = sp['id'];
                                final spName = "${sp['first_name']} ${sp['last_name']}";

                                return ExpansionTile(
                                  key: ValueKey("sp_$spId"),
                                  title: _expandedSpIds.contains(spId)
                                      ? Text(spName)
                                      : AbsorbPointer(child: _buildKaryakarthaProfile(sp, allowTap: false)),
                                  onExpansionChanged: (expanded) {
                                    setState(() {
                                      if (expanded) {
                                        _expandedSpIds.add(spId);
                                      } else {
                                        _expandedSpIds.remove(spId);
                                      }
                                    });
                                  },
                                  children: [
                                    ListTile(
                                      title: _buildKaryakarthaProfile(sp, allowTap: false),
                                      onTap: () => _showConfirmationDialog(spName, spId, sp,mj,mj['level'],mj),
                                    ),
                                    ...?shreniPramukhGatanayaks[spId]?.map((gk) {
                                      final gkName = "${gk['first_name']} ${gk['last_name']}";
                                      return ListTile(
                                        title: _buildKaryakarthaProfile(gk, allowTap: false),
                                        onTap: () => _showConfirmationDialog(gkName, gk['id'], gk,mj,mj['level'],sp),
                                      );
                                    }),
                                  ],
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKaryakarthaProfile(dynamic karyakartha, {bool allowTap = true}) {
    if (karyakartha.isEmpty) return Text("No Karyakartha available.");

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, top: 0),
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: true,
                child: MemberCard(
                  first_name: karyakartha['first_name'],
                  last_name: karyakartha['last_name'],
                  designation: karyakartha['designation'],
                  profileImage: karyakartha['profile_image'] ?? '',
                  id: karyakartha['id'],
                ),
              ),
              if (allowTap)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      //_showConfirmationDialog("${karyakartha['first_name']} ${karyakartha['last_name']}",karyakartha['id'], karyakartha);
                    },
                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(karyakartha['id']),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildUserGatanayakSections() {
    final gks = shreniPramukhGatanayaks[widget.userId];
    if (gks == null || gks.isEmpty) return [Text("No Gatanayaks under you.")];
    return gks.map((gk) => _buildGatanayakSection(gk)).toList();
  }

  Widget _buildShreniPramukhSection(dynamic sp) {
    final spId = sp['id'];
    final spName = "${sp['first_name']} ${sp['last_name']}";

    return ExpansionTile(
      title: Text(spName, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Influencers under $spName"),
              _buildInfluencerSelectionList(shreniPramukhInfluencers[spId] ?? [], 'shreni_$spId'),
              SizedBox(height: 10),
              Text("Gatanayaks under $spName"),
              ...?shreniPramukhGatanayaks[spId]?.map((gk) => _buildGatanayakSection(gk)).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGatanayakSection(dynamic gk) {
    final gkId = gk['id'];
    final gkName = "${gk['first_name']} ${gk['last_name']}";

    return ExpansionTile(
      title: Text(gkName, style: TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: _buildInfluencerSelectionList(gatanayakInfluencers[gkId] ?? [], 'gatanayak_$gkId'),
        ),
      ],
    );
  }

  Widget _buildMJSPSection(dynamic mj) {
    final mjId = mj['id'];
    final mjName = "${mj['first_name']} ${mj['last_name']}";

    return ExpansionTile(
      title: Text(mjName, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Influencers under $mjName"),
            _buildInfluencerSelectionList(mjSPInfluencers[mjId] ?? [], 'mjsp_$mjId'),
            SizedBox(height: 10),

            // Gatanayaks directly under MJSP
            Text("Gatanayaks under $mjName"),
            ...?mjSPGatanayaks[mjId]?.map((gk) => _buildGatanayakSection(gk)).toList(),

            SizedBox(height: 10),
            // Shreni Pramukhs under this MJSP
            if ((mjSPShreniPramukhs[mjId]?.isNotEmpty ?? false))
              Text("Shreni Pramukhs under $mjName", style: TextStyle(fontWeight: FontWeight.bold)),
            ...?mjSPShreniPramukhs[mjId]?.map((sp) => _buildShreniUnderMJSection(sp)).toList(),
          ]),
        ),
      ],
    );
  }

  // Nested Shreni UI under MJSP
  Widget _buildShreniUnderMJSection(dynamic sp) {
    final spId = sp['id'];
    final spName = "${sp['first_name']} ${sp['last_name']}";

    return ExpansionTile(
      title: Text(spName, style: TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Influencers under $spName"),
            _buildInfluencerSelectionList(shreniPramukhInfluencers[spId] ?? [], 'mjshreni_$spId'),
            SizedBox(height: 10),
            Text("Gatanayaks under $spName"),
            ...?shreniPramukhGatanayaks[spId]?.map((gk) => _buildGatanayakSection(gk)).toList(),
          ]),
        ),
      ],
    );
  }

  Widget _buildInfluencerSelectionList(List<dynamic> influencers, String listKey) {
    if (influencers.isEmpty) return Text("No influencers available.");
    final isExpanded = expandedLists.contains(listKey);
    final displayList = isExpanded || influencers.length <= 3
        ? influencers
        : influencers.sublist(0, 3);

    return Column(
      children: [
        ...displayList.map((influencer) {
          final id = influencer['id'];
          final fullName = "${influencer['fname']} ${influencer['lname']}";
          final isSelected = selectedInfluencerIds.contains(id);

          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
            child: Stack(
              children: [
                AbsorbPointer(
                  absorbing: true,
                  child: InfluencerCard(
                    id: id,
                    name: fullName,
                    designation: influencer['designation'] ?? '',
                    description: influencer['description'] ?? '',
                    hashtags: getHashtagNames(influencer['hashtags'], hashtags),
                    soochi: influencer['soochi'] ?? '',
                    shreni: influencer['shreni'] ?? '',
                    itrLvl: influencer['interaction_level'] ?? '',
                    profileImage: influencer['profile_image'] ?? '',
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => _toggleInfluencerSelection(id),
                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfluencerProfilePage(id),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black.withOpacity(0.3) : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: isSelected
                          ? Center(
                        child: Icon(Icons.check_circle, size: 35, color: Colors.white),
                      )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (influencers.length > 3)
          TextButton(
            onPressed: () {
              setState(() {
                isExpanded
                    ? expandedLists.remove(listKey)
                    : expandedLists.add(listKey);
              });
            },
            child: Text(isExpanded ? "Show Less" : "Show All"),
          ),
      ],
    );
  }

  void _showMigrationTargetDialogORG(BuildContext context, dynamic karyakartha,dynamic supervisor, int supervisorLvl,dynamic shreniPramukh) {
    print('groups: $groups');
    if(karyakartha['level'] == 1){
      print(karyakartha);
    }
    print('$selectedGroupId - ${karyakartha['level']}');
    showDialog(
      context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text("Select Target Position"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group Dropdown
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Background color
                          borderRadius: BorderRadius.circular(15), // Rounded corners
                          border: Border.all(
                            color: Colors.grey.shade400, // Border color when not focused
                            width: 1.0, // Border width
                          ),
                        ),
                        child: DropdownButton<String>(
                          hint: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(groups.isNotEmpty ? 'Select Group' : 'Loading groups..'),
                          ),
                          value: selectedGroupId,
                          onChanged: (String? newValue) async {
                            if (newValue == '1') {
                              fetchMembers();
                            }
                            selectedGroupId = newValue;
                            if(newValue == '1'){
                              selectedShreniPramukhId = karyakartha['lead'];
                            }
                            selectedSupervisorId = karyakartha['supervisor'];
                            print('new value: $newValue');
                            setState(() {

                            });
                          },
                          items: (() {
                            int lvl = apiService.lvl;
                            List groupSubset;

                            if (lvl == 3 || lvl == 4) {
                              // Limit to first 3 items
                              groupSubset = groups.length > 2 ? groups.sublist(0, 2) : groups;
                            } else if (lvl == 10) {
                              // Limit to first 3 items
                              groupSubset = groups.length > 2 ? groups.sublist(0, lvl) : groups;
                            } else {
                              // Show from index 0 up to (lvl - 1)
                              groupSubset = groups.length >= lvl ? groups.sublist(0, lvl-1) : groups;
                            }

                            return groupSubset.map<DropdownMenuItem<String>>((group) {
                              return DropdownMenuItem<String>(
                                value: group['id'].toString(),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child:
                                  Text(karyakartha['level']==group['id']?'${group['name']} (current)':group['name']),
                                ),
                              );
                            }).toList();
                          })(),
                          isExpanded: true,
                          underline: Container(),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Select supervisor
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 1.0, // Border width
                          ),
                        ),
                        child: DropdownButton<String>(
                          hint: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(members.isNotEmpty ? 'Select supervisor' : 'Loading supervisor..'),
                          ),
                          value: selectedSupervisorId,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSupervisorId = newValue;
                            });
                          },
                          items: members.map<DropdownMenuItem<String>>((member) {
                            return DropdownMenuItem<String>(
                              value: member['id'].toString(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${member['first_name']} ${member['last_name']}'),
                              ),
                            );
                          }).toList(),
                          isExpanded: true, // Ensures the dropdown stretches to the full width
                          underline: Container(), // Removes the default underline from the dropdown
                        ),
                      ),
                      if (selectedGroupId=='1')
                        SizedBox(height: 20),
                      // Select Shreni pramukh if id =1
                      if (selectedGroupId=='1')
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.0, // Border width
                            ),
                          ),
                          child: DropdownButton<String>(
                            hint: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(members.isNotEmpty ? 'Select ShreniPramuhk' : 'Loading ShreniPramuhk..'),
                            ),
                            value: selectedKaryakarthaId,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedKaryakarthaId = newValue;
                              });
                            },
                            items: members.map<DropdownMenuItem<String>>((member) {
                              return DropdownMenuItem<String>(
                                value: member['id'].toString(),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('${member['first_name']} ${member['last_name']}'),
                                ),
                              );
                            }).toList(),
                            isExpanded: true, // Ensures the dropdown stretches to the full width
                            underline: Container(), // Removes the default underline from the dropdown
                          ),
                        ),
                      if (selectedGroupId=='1'|| selectedGroupId=='2')
                        SizedBox(height: 20),
                      //Shreni if group id
                      if (selectedGroupId=='1' || selectedGroupId=='2')
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade400, width: 1.0),
                          ),
                          child: DropdownButton<String>(
                            hint: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('Select Shreni'),
                            ),
                            value: selectedShreni,
                            onChanged: (String? newShreni) {
                              setState(() {
                                selectedShreni = newShreni;
                              });
                            },
                            items: shrenis.map<DropdownMenuItem<String>>((shreni) {
                              return DropdownMenuItem<String>(
                                value: shreni,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(shreni),
                                ),
                              );
                            }).toList(),
                            isExpanded: true,
                            underline: Container(),
                          ),
                        ),
                      SizedBox(height: 20),
                      //continue button
                      if ((selectedGroupId != karyakartha['level'].toString()) || (selectedGroupId == 1 && karyakartha['level']==1 && selectedShreni!=karyakartha['lead']))
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
                              isLoading = true; // Show loading indicator
                            });
                            setState(() {
                              isLoading = false; // Hide loading indicator
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 10), // Adjust padding
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,  // Center the row content
                              children: [
                                const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 23,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),  // Add space between the text and the image
                                Transform.rotate(
                                  angle: 4.7124,  // Rotate the arrow 90 degrees
                                  child: Image.asset(
                                    'assets/icon/arrow.png',
                                    color: Colors.white,
                                    width: 15,  // Adjust the size of the image
                                    height: 15, // Adjust the size of the image
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
              );
            },
          );
        },
    );

  }

  void _showMigrationTargetDialog(BuildContext context, dynamic karyakartha, dynamic supervisor, int supervisorLvl, dynamic shreniPramukh) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<dynamic> validGroups = groups.where((group) {
              int groupLevel = int.tryParse(group['id'].toString()) ?? 0;
              return group['id'].toString() == selectedGroupId || groupLevel != karyakartha['level'];
            }).toList();

            // Prevent duplicate items with same ID
            final seenIds = <String>{};
            validGroups = validGroups.where((group) {
              final id = group['id'].toString();
              if (seenIds.contains(id)) return false;
              seenIds.add(id);
              return true;
            }).toList();


            bool isShreniRequired = selectedGroupId == '1' || selectedGroupId == '2';
            bool isShreniPramukhRequired = selectedGroupId == '1';

            return AlertDialog(
              title: Text("Select Target Position"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Group selection
                    _buildStyledDropdown(
                      context: context,
                      hint: groups.isEmpty ? 'Loading groups..' : 'Select Group',
                      value: selectedGroupId,
                      items: validGroups.map((group) {
                        return DropdownMenuItem<String>(
                          value: group['id'].toString(),
                          child: Text(karyakartha['level'] == group['id'] ? '${group['name']} (current)' : group['name']),
                        );
                      }).toList(),
                      onChanged: (val) async {
                        setState(() {
                          selectedGroupId = val;
                          selectedSupervisorId = null;
                          selectedKaryakarthaId = null;
                        });

                        // Fetch members if group is L1
                        if (val == '1') {
                          await fetchMembers();
                        }
                      },
                    ),

                    SizedBox(height: 20),

                    // Supervisor
                    _buildStyledDropdown(
                      context: context,
                      hint: 'Select Supervisor',
                      value: selectedSupervisorId,
                      items: members.map((member) {
                        return DropdownMenuItem<String>(
                          value: member['id'].toString(),
                          child: Text('${member['first_name']} ${member['last_name']}'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedSupervisorId = val),
                    ),

                    if (isShreniPramukhRequired) ...[
                      SizedBox(height: 20),
                      // ShreniPramukh
                      _buildStyledDropdown(
                        context: context,
                        hint: 'Select Shreni Pramukh',
                        value: selectedKaryakarthaId,
                        items: members.map((member) {
                          return DropdownMenuItem<String>(
                            value: member['id'].toString(),
                            child: Text('${member['first_name']} ${member['last_name']}'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedKaryakarthaId = val),
                      ),
                    ],

                    if (isShreniRequired) ...[
                      SizedBox(height: 20),
                      // Shreni
                      _buildStyledDropdown(
                        context: context,
                        hint: 'Select Shreni',
                        value: selectedShreni,
                        items: shrenis.map((shreni) {
                          return DropdownMenuItem<String>(
                            value: shreni,
                            child: Text(shreni),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedShreni = val),
                      ),
                    ],

                    SizedBox(height: 30),

                    // Continue button
                    if (_isMigrationValid(karyakartha))
                      Container(
                        width: double.infinity,
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
                            // Trigger migration logic
                            Navigator.of(context).pop();
                            // TODO: Call API with selectedGroupId, selectedSupervisorId, selectedShreni, etc.
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Transform.rotate(
                                angle: 4.7124,
                                child: Image.asset(
                                  'assets/icon/arrow.png',
                                  color: Colors.white,
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  var karyakarthaHasInfluencers = false;
  var karyakarthaHasInfluencersAcknowledged = false;

  void _showTransferTargetDialog(BuildContext context, dynamic karyakartha, dynamic supervisor, int supervisorLvl, dynamic shreniPramukh) {
    String selectedGroupId = karyakartha['level'].toString();
    int positionId = selectedGroupId == '1'
        ? int.parse(selectedGroupId) + 2
        : int.parse(selectedGroupId) + 1;
    selectedSupervisorId = null;
    selectedKaryakarthaId = null;
    selectedShreni = null;
    selectedShreniPramukhId = null;
    karyakarthaHasInfluencers = false;
    karyakarthaHasInfluencersAcknowledged = false;
    var karyakarthaHasInfluencersChecked = false;
    print('karyakarth : $karyakartha');
    print('karyakartha.runtimeType: ${karyakartha.runtimeType}');
    if (karyakartha['shreni'] != null && shrenis.contains(karyakartha['shreni'])) {
      selectedShreni = karyakartha['shreni'];
    }

    List<dynamic> validGroups = groups.where((group) {
      int groupLevel = int.tryParse(group['id'].toString()) ?? 0;
      return group['id'].toString() == selectedGroupId || groupLevel != karyakartha['level'];
    }).toList();

    // Prevent duplicate items with same ID
    final seenIds = <String>{};
    validGroups = validGroups.where((group) {
      final id = group['id'].toString();
      if (seenIds.contains(id)) return false;
      seenIds.add(id);
      return true;
    }).toList();


    bool isShreniRequired = selectedGroupId == '1' || selectedGroupId == '2';
    bool isShreniPramukhRequired = selectedGroupId == '1';

    List<dynamic>? getSupervisorsData() {
      if (selectedGroupId == '3') {
        return mjSP;
      } else if (selectedGroupId == '4') {
        return mjSP;
      } else {
        return mjSP;
      }
    }

    Future<bool> checkKaryakarthaHasInfluencer() async {
      int count = await apiService.getInfluencerCount(karyakartha['id']);
      karyakarthaHasInfluencers = count > 0;
      karyakarthaHasInfluencersAcknowledged = !karyakarthaHasInfluencers;
      return karyakarthaHasInfluencers;
    }

    List<dynamic> getShreniPramukhData() {
      if (selectedSupervisorId == apiService.UserId) {
        return myShreniPramukhs;
      }

      if (selectedGroupId == '3' || selectedGroupId == '4') {
        return mjSP;
      }

      final supervisors = getSupervisorsData();
      final supervisor = supervisors?.firstWhere(
            (member) => member['id'].toString() == selectedSupervisorId,
        orElse: () => null,
      );

      final pramukhs = mjSPShreniPramukhs[selectedSupervisorId];

      if (pramukhs == null || pramukhs.isEmpty) {
        return supervisor != null ? [supervisor] : [];
      }

      final pramukhList = List<Map<String, dynamic>>.from(pramukhs);
      final alreadyExists = pramukhList.any(
            (member) => member['id'].toString() == selectedSupervisorId,
      );

      if (!alreadyExists && supervisor != null) {
        pramukhList.add(supervisor);
      }

      return pramukhList;
    }


    var positions = ['none','none','none','MSP or JSP','MSP or JSP','Vibhaga Samparka Pramukh','Pranthya Samparka Pramukh','Mahanagara Samparka Pramukh','Mahanagara Samparka Pramukh'];
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Stack(
          children: [
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: Text("Select Karyakartha you want to transfer under"),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Supervisor
                        _buildStyledDropdown(
                          context: context,
                          hint: 'Select ${positions[positionId]}',
                          value: selectedSupervisorId,
                          items: getSupervisorsData()!.map((member) {
                            return DropdownMenuItem<String>(
                              value: member['id'],
                              child: Text('  ${member['first_name']} ${member['last_name']}'),
                            );
                          }).toList(),
                          onChanged: (val) async {
                            setState(() {
                              selectedShreniPramukhId = null;
                              selectedSupervisorId = val;

                              // checking Shreni Pramukh
                              final pramukhs = mjSPShreniPramukhs[val];
                              if (pramukhs == null || pramukhs.isEmpty && int.parse(selectedGroupId)==1) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text("No Shreni Pramukh Found"),
                                      content: Text(
                                        "No Shreni Pramukh available under this supervisor. Please select Supervisor as Shreni Pramukh.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              }

                              //check for influencer under user, to other than gatanayak
                              if(int.parse(selectedGroupId)>2 && selectedSupervisorId!=null){
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text("Influencers Found"),
                                      content: Text(
                                        "Before Proceeding:\n This Karyakartha has assigned influencers. Do you want to keep them here or transfer them to another Karyakartha?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            // Add logic to keep influencers with the current Karyakartha
                                            //handleKeepInfluencers();
                                          },
                                          child: Text("Keep with Current"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            // Navigate to transfer screen or show another dialog
                                            //handleTransferInfluencers();
                                          },
                                          child: Text("Transfer to Another"),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              }

                            });
                            // check for influencer under user, for gatanayak and Shreni Pramukh
                            if ((int.parse(selectedGroupId) == 1 && selectedSupervisorId != null && selectedShreniPramukhId != null && selectedShreni != null) ||
                                (int.parse(selectedGroupId) == 2 && selectedSupervisorId != null && selectedShreni != null)) {
                              isLoading = true;
                              bool hasInfluencers = await checkKaryakarthaHasInfluencer();
                              isLoading = false;
                              if (hasInfluencers) {
                                setState(() {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                      _) {
                                    showDialog(
                                      context: context,
                                      builder: (_) =>
                                          AlertDialog(
                                            title: Text("Influencers Found"),
                                            content: Text(
                                              "Before Proceeding:\n This Karyakartha has assigned influencers. Do you want to keep them here or transfer them to another Karyakartha?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  setState(()
                                                  {
                                                    karyakarthaHasInfluencersAcknowledged = true;
                                                  }
                                                  );
                                                  Navigator.of(context).pop();
                                                  // Add logic to keep influencers with the current Karyakartha
                                                },
                                                child: Text("Keep with Current"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  setState((){migrateInfluencer = true;});
                                                  print('karyakartha.runtimeType: ${karyakartha.runtimeType}');
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => MigrateInfluencerForUserPage(karyakartha['id'], karyakartha: karyakartha,),
                                                    ),
                                                  );
                                                  // Add logic to transfer influencers
                                                },
                                                child: Text(
                                                    "Transfer to Another"),
                                              ),
                                            ],
                                          ),
                                    );
                                  });
                                });
                              }
                            }
                          },
                        ),


                        //Shreni Pramukh
                        if (isShreniPramukhRequired  && selectedSupervisorId != null) ...[
                          SizedBox(height: 20),
                          // ShreniPramukh
                          _buildStyledDropdown(
                            context: context,
                            hint: 'Select Shreni Pramukh',
                            value: selectedShreniPramukhId,
                            items: getShreniPramukhData().map<DropdownMenuItem<String>>((member) {
                              return DropdownMenuItem<String>(
                                value: member['id'].toString(),
                                child: Text('  ${member['first_name']} ${member['last_name']}'),
                              );
                            }).toList(),
                            onChanged: (val) async {
                              // Update state with selected value first
                              setState(() {
                                selectedShreniPramukhId = val;
                              });

                              log('selected shreni $selectedShreni');
                              log('selected Groupid: $selectedGroupId');
                              log('Selected Supervisor: $selectedSupervisorId');
                              log('Selected Shreni Pramukh: $selectedShreniPramukhId');
                              log('Selected Shreni: $selectedShreni');

                              // check for influencer under user, for gatanayak and shreni pramukh
                              if ((int.parse(selectedGroupId) == 1 && selectedSupervisorId != null && selectedShreniPramukhId != null && selectedShreni != null) ||
                                  (int.parse(selectedGroupId) == 2 && selectedSupervisorId != null && selectedShreni != null)) {
                                if(!karyakarthaHasInfluencersChecked){
                                  isLoading = true;
                                  bool hasInfluencers = await checkKaryakarthaHasInfluencer();
                                  print('Has influencers: $hasInfluencers');
                                  karyakarthaHasInfluencersChecked = true;
                                  setState((){});
                                  isLoading = false;
                                  if (hasInfluencers) {
                                    setState(() {
                                      WidgetsBinding.instance.addPostFrameCallback((
                                          _) {
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                              AlertDialog(
                                                title: Text("Influencers Found"),
                                                content: Text(
                                                  "Before Proceeding:\n This Karyakartha has assigned influencers. Do you want to keep them here or transfer them to another Karyakartha?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(()
                                                      {
                                                        karyakarthaHasInfluencersAcknowledged = true;
                                                      }
                                                      );
                                                      Navigator.of(context).pop();
                                                      // Add logic to keep influencers with the current Karyakartha
                                                    },
                                                    child: Text("Keep with Current"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      setState((){
                                                        migrateInfluencer = true;
                                                      });
                                                      // Add logic to transfer influencers
                                                    },
                                                    child: Text(
                                                        "Transfer to Another"),
                                                  ),
                                                ],
                                              ),
                                        );
                                      });
                                    });
                                  }
                                }
                              }
                            },

                          ),
                        ],



                        //select shreni
                        if (isShreniRequired) ...[
                          SizedBox(height: 20),
                          // Shreni
                          _buildStyledDropdown(
                            context: context,
                            hint: ' Select Shreni',
                            value: selectedShreni,
                            items: shrenis.map((shreni) {
                              return DropdownMenuItem<String>(
                                value: shreni,
                                child: Text('  $shreni'),
                              );
                            }).toList(),
                            onChanged: (val) async {
                              // Update state with selected value first
                              setState(() {
                                selectedShreni = val;
                              });

                              log('selected shreni $selectedShreni');

                              // check for influencer under user, for gatanayak and Shreni Pramukh
                              if ((int.parse(selectedGroupId) == 1 && selectedSupervisorId != null && selectedShreniPramukhId != null && selectedShreni != null) ||
                                  (int.parse(selectedGroupId) == 2 && selectedSupervisorId != null && selectedShreni != null)) {
                                isLoading = true;
                                bool hasInfluencers = await checkKaryakarthaHasInfluencer();
                                isLoading = false;
                                if (hasInfluencers) {
                                  setState(() {
                                    WidgetsBinding.instance.addPostFrameCallback((
                                        _) {
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            AlertDialog(
                                              title: Text("Influencers Found"),
                                              content: Text(
                                                "Before Proceeding:\n This Karyakartha has assigned influencers. Do you want to keep them here or transfer them to another Karyakartha?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    setState(()
                                                    {
                                                      karyakarthaHasInfluencersAcknowledged = true;
                                                    }
                                                    );
                                                    Navigator.of(context).pop();
                                                    // Add logic to keep influencers with the current Karyakartha
                                                  },
                                                  child: Text("Keep with Current"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    setState((){migrateInfluencer = true;});
                                                    print('karyakartha.runtimeType: ${karyakartha.runtimeType}');
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => MigrateInfluencerForUserPage(karyakartha['id'], karyakartha: karyakartha,),
                                                      ),
                                                    );
                                                    // Add logic to transfer influencers
                                                  },
                                                  child: Text("Transfer to Another"),
                                                ),
                                              ],
                                            ),
                                      );
                                    });
                                  });
                                }
                              }
                            },
                          ),
                        ],

                        SizedBox(height: 30),

                        if (_isMigrationValid(karyakartha)) ...[
                          Container(
                            width: double.infinity,
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
                                // Trigger migration logic
                                Navigator.of(context).pop();
                                // TODO: Call API with selectedGroupId, selectedSupervisorId, selectedShreni, etc.
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontSize: 23,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Transform.rotate(
                                    angle: 4.7124,
                                    child: Image.asset(
                                      'assets/icon/arrow.png',
                                      color: Colors.white,
                                      width: 15,
                                      height: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            if(isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
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
        );
      },
    );
  }

  /*gpt ^*/

  Widget _buildStyledDropdown({
    required BuildContext context,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade400, width: 1.0),
      ),
      child: DropdownButton<String>(
        hint: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(hint),
        ),
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: Container(),
      ),
    );
  }

  bool _isMigrationValid(dynamic karyakartha) {
    log('validate called');
    log('karyakarthaHasInfluencersAcknowledged ${!karyakarthaHasInfluencersAcknowledged}');
    log('selectedGroupId $selectedGroupId');
    log('selectedSupervisorId $selectedSupervisorId');
    log('selectedShreniPramukhId $selectedShreniPramukhId');
    log('selectedShreni $selectedShreni');

    if (selectedGroupId == null || selectedSupervisorId == null) return false;
    log('check1 complete');
    if ((selectedGroupId == '1' || selectedGroupId == '2') && selectedShreni == null) return false;
    log('check2 complete');
    if (selectedGroupId == '1' && (selectedSupervisorId == null || selectedShreniPramukhId == null)) return false;
    log('check3 complete');
    if(karyakarthaHasInfluencersAcknowledged == false) return false;
    log('check4 complete');
    log('validated');

    return true;
  }

  /* end gpt */

  void _showConfirmationDialogORG(String userName, String userId, dynamic karyakartha,dynamic supervisor, int supervisorLvl,dynamic shreniPramukh) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Transfer"),
          content: Text("Do you want to transfer to $userName?"),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation
                selectedGroupId = karyakartha['level'].toString();
                _showMigrationTargetDialog(context,karyakartha,supervisor,supervisorLvl,shreniPramukh);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(String userName, String userId, dynamic karyakartha,dynamic supervisor, int supervisorLvl,dynamic shreniPramukh) {
    showDialog(
      context: context,
      builder: (context) {
        var migrateInfluencerChecked = false;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Transfer Options",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose how you want to proceed with $userName:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  selectedGroupId = karyakartha['level'].toString();
                  _showTransferTargetDialog(context, karyakartha, supervisor, supervisorLvl, shreniPramukh);
                },
                icon: Icon(Icons.sync_alt),
                label: Text("Transfer (Keep Same Position)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 45),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle change position logic here
                  _showChangePositionDialog(context, karyakartha); // You can define this method
                },
                icon: Icon(Icons.swap_horiz),
                label: Text("Change Position"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: Size(double.infinity, 45),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMigrateInfluencerDialog(String userName, String userId, dynamic karyakartha,dynamic supervisor, int supervisorLvl,dynamic shreniPramukh) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Influencers Found"),
          content: Text(
            "Before Proceeding:\n This Karyakartha has assigned influencers. Do you want to keep them here or transfer them to another Karyakartha?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Add logic to keep influencers with the current Karyakartha
                //handleKeepInfluencers();
              },
              child: Text("Keep with Current"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to transfer screen or show another dialog
                //handleTransferInfluencers();
              },
              child: Text("Transfer to Another"),
            ),
          ],
        );
      },
    );
  }


  void _migrationCard(String userName, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child:
          Column(
            children: [
              // Group Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Background color
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                  border: Border.all(
                    color: Colors.grey.shade400, // Border color when not focused
                    width: 1.0, // Border width
                  ),
                ),
                child: DropdownButton<String>(
                  hint: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(groups.isNotEmpty ? 'Select Group' : 'Loading groups..'),
                  ),
                  value: selectedGroupId,
                  onChanged: (String? newValue) async {
                    if (newValue == '1') {
                      fetchMembers();
                    }
                    setState(() {
                      selectedGroupId = newValue;
                    });
                  },
                  items: (() {
                    int lvl = apiService.lvl;
                    List groupSubset;

                    if (lvl == 3 || lvl == 4) {
                      // Limit to first 3 items
                      groupSubset = groups.length > 2 ? groups.sublist(0, 2) : groups;
                    } else if (lvl == 10) {
                      // Limit to first 3 items
                      groupSubset = groups.length > 2 ? groups.sublist(0, lvl) : groups;
                    } else {
                      // Show from index 0 up to (lvl - 1)
                      groupSubset = groups.length >= lvl ? groups.sublist(0, lvl-1) : groups;
                    }



                    return groupSubset.map<DropdownMenuItem<String>>((group) {
                      return DropdownMenuItem<String>(
                        value: group['id'].toString(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(group['name']),
                        ),
                      );
                    }).toList();
                  })(),
                  isExpanded: true,
                  underline: Container(),
                ),
              ),
              if (selectedGroupId=='1')
                SizedBox(height: 20),
              // Select Shreni pramukh if id =1
              if (selectedGroupId=='1')
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1.0, // Border width
                    ),
                  ),
                  child: DropdownButton<String>(
                    hint: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(members.isNotEmpty ? 'Select ShreniPramuhk' : 'Loading ShreniPramuhk..'),
                    ),
                    value: selectedKaryakarthaId,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedKaryakarthaId = newValue;
                      });
                    },
                    items: members.map<DropdownMenuItem<String>>((member) {
                      return DropdownMenuItem<String>(
                        value: member['id'].toString(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('${member['first_name']} ${member['last_name']}'),
                        ),
                      );
                    }).toList(),
                    isExpanded: true, // Ensures the dropdown stretches to the full width
                    underline: Container(), // Removes the default underline from the dropdown
                  ),
                ),
              if (selectedGroupId=='1'|| selectedGroupId=='2')
                SizedBox(height: 20),
              //Shreni if group id
              if (selectedGroupId=='1' || selectedGroupId=='2')
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade400, width: 1.0),
                  ),
                  child: DropdownButton<String>(
                    hint: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Select Shreni'),
                    ),
                    value: selectedShreni,
                    onChanged: (String? newShreni) {
                      setState(() {
                        selectedShreni = newShreni;
                      });
                    },
                    items: shrenis.map<DropdownMenuItem<String>>((shreni) {
                      return DropdownMenuItem<String>(
                        value: shreni,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(shreni),
                        ),
                      );
                    }).toList(),
                    isExpanded: true,
                    underline: Container(),
                  ),
                ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _showChangePositionDialog {
  _showChangePositionDialog(BuildContext context, karyakartha);
}

class MemberCard extends StatelessWidget {
  final String id;
  final String first_name;
  final String last_name;
  final String designation;
  final String profileImage;

  const MemberCard({
    super.key,

    required this.first_name,
    required this.last_name,
    required this.designation,
    required this.profileImage,
    required this.id,

  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    //log(' KR received $first_name $last_name');
    return Container(
      padding: const EdgeInsets.all(0), // Container padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
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
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 0,right: 0,bottom: 8,top: 8), // Add padding to the content
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
                          child: Icon(Icons.error, color: Colors.grey[400],size: MediaQuery.of(context).size.width * 0.075),  // Display error icon
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
                        fontSize: largeFontSize+6,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                    Text(
                      designation, // Dynamic designation
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
