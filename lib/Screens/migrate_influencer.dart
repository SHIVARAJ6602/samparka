import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Service/api_service.dart';
import '../widgets/influencer_card.dart';
import 'influencer_profile.dart';

class MigrateInfluencerPage extends StatefulWidget {
  final String userId; // current user id

  const MigrateInfluencerPage(this.userId, {super.key});

  @override
  MigrateInfluencerPageState createState() => MigrateInfluencerPageState();
}

class MigrateInfluencerPageState extends State<MigrateInfluencerPage> {
  final apiService = ApiService();

  bool loading = true;

  List<dynamic> myInfluencers = [];
  List<dynamic> shreniPramukhs = [];
  List<dynamic> mjSP = [];
  List<dynamic> gatanayaks = [];
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

  @override
  void initState() {
    super.initState();
    _loadAllData();
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

  Future<void> _loadAllData() async {
    setState(() => loading = true);
    var lvl = apiService.lvl;

    try {
      fetchHashtags();

      myInfluencers = formatInfluencers(await fetchInfluencersForUser(widget.userId));
      final myGatanayaks = await apiService.getGatanayak(widget.userId);
      shreniPramukhGatanayaks[widget.userId] = myGatanayaks;

      for (var gk in myGatanayaks) {
        gatanayakInfluencers[gk['id']] = formatInfluencers(await fetchInfluencersForUser(gk['id']));
      }

      if (lvl > 2) {
        shreniPramukhs = await apiService.getShreniPramukhs(apiService.UserId);
        for (var sp in shreniPramukhs) {
          final spId = sp['id'];
          shreniPramukhInfluencers[spId] = formatInfluencers(await fetchInfluencersForUser(spId));
          final gatanayaks = await apiService.getGatanayak(spId);
          shreniPramukhGatanayaks[spId] = gatanayaks;

          for (var gk in gatanayaks) {
            gatanayakInfluencers[gk['id']] = formatInfluencers(await fetchInfluencersForUser(gk['id']));
          }
        }
      }

      if (lvl > 4) {
        mjSP = await apiService.myMJMembers(0, 100);
        for (var mj in mjSP) {
          final mjId = mj['id'];
          // influencers directly under MJSP
          mjSPInfluencers[mjId] = formatInfluencers(await fetchInfluencersForUser(mjId));
          // gatanayaks directly under MJSP
          final mjGk = await apiService.getGatanayak(mjId);
          mjSPGatanayaks[mjId] = mjGk;
          // shreni pramukh under MJSP
          final mjSPShrenis = await apiService.getShreniPramukhs(mjId);
          mjSPShreniPramukhs[mjId] = mjSPShrenis;

          // loop each Shreni under MJSP
          for (var sp in mjSPShrenis) {
            final spId = sp['id'];
            shreniPramukhInfluencers[spId] = formatInfluencers(await fetchInfluencersForUser(spId));
            final spGk = await apiService.getGatanayak(spId);
            shreniPramukhGatanayaks[spId] = spGk;
            for (var gk in spGk) {
              gatanayakInfluencers[gk['id']] = formatInfluencers(await fetchInfluencersForUser(gk['id']));
            }
          }

          // loop MJSP → Gatanayaks
          for (var gk in mjGk) {
            gatanayakInfluencers[gk['id']] = formatInfluencers(await fetchInfluencersForUser(gk['id']));
          }
        }
      }

    } catch (e) {
      log('Error loading data: $e');
    }

    setState(() => loading = false);
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
          title: Text("Migrate Influencers"),
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
          title: Text("Migrate Influencers"),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Influencers", style: Theme.of(context).textTheme.titleLarge),
              _buildInfluencerSelectionList(myInfluencers, 'myInfluencers'),

              Divider(height: 40),
              Text("My Gatanayaks", style: Theme.of(context).textTheme.titleLarge),
              ..._buildUserGatanayakSections(),

              Divider(height: 40),
              Text("Shreni Pramukhs", style: Theme.of(context).textTheme.titleLarge),
              ...shreniPramukhs.map((sp) => _buildShreniPramukhSection(sp)).toList(),

              Divider(height: 40),
              Text("MJSPs", style: Theme.of(context).textTheme.titleLarge),
              ...mjSP.map((mj) => _buildMJSPSection(mj)).toList(),

              SafeArea(child: SizedBox(height: 80)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Color.fromRGBO(59, 171, 144, 1.0),
            onPressed: () => _showMigrationTargetDialog(context),
    label: Text('Migrate Selected', style: TextStyle(color: Colors.white)),
    icon: Icon(Icons.swap_horiz, size: 25, color: Colors.white),
    ),
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

  void _showMigrationTargetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Select Migration Target"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text("My Account"),
                  subtitle: Text(apiService.first_name),
                  onTap: () => _showConfirmationDialog(apiService.first_name, widget.userId),
                ),

                if ((shreniPramukhGatanayaks[widget.userId]?.isNotEmpty ?? false))
                  ExpansionTile(
                    title: Text("My Gatanayaks"),
                    children: [
                      ...?shreniPramukhGatanayaks[widget.userId]?.map((gk) {
                        final gkId = gk['id'];
                        final gkName = "${gk['first_name']} ${gk['last_name']}";
                        return ListTile(
                          title: Text(gkName),
                          onTap: () => _showConfirmationDialog(gkName, gkId),
                        );
                      }).toList(),
                    ],
                  ),

                Divider(),

                ExpansionTile(
                  title: Text("Shreni Pramukhs"),
                  children: shreniPramukhs.map((sp) {
                    final spId = sp['id'];
                    final spName = "${sp['first_name']} ${sp['last_name']}";

                    return ExpansionTile(
                      title: Text(spName),
                      children: [
                        ListTile(
                          title: Text(spName),
                          onTap: () => _showConfirmationDialog(spName, spId),
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
                            title: Text(gkName),
                            onTap: () => _showConfirmationDialog(gkName, gkId),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ),

                Divider(),

                if (mjSP.isNotEmpty)
                  ExpansionTile(
                    title: Text("MJSPs"),
                    children: mjSP.map((mj) {
                      final mjId = mj['id'];
                      final mjName = "${mj['first_name']} ${mj['last_name']}";

                      return ExpansionTile(
                        title: Text(mjName),
                        children: [
                          ListTile(
                            title: Text(mjName),
                            onTap: () => _showConfirmationDialog(mjName, mjId),
                          ),

                          // Gatanayaks...
                          ...?mjSPGatanayaks[mjId]?.map((gk) => ListTile(
                            title: Text("${gk['first_name']} ${gk['last_name']}"),
                            onTap: () => _showConfirmationDialog("${gk['first_name']} ${gk['last_name']}", gk['id']),
                          )),

                          // Shreni under MJSP
                          ...?mjSPShreniPramukhs[mjId]?.map((sp) {
                            final spId = sp['id'];
                            final spName = "${sp['first_name']} ${sp['last_name']}";
                            return ExpansionTile(
                              title: Text(spName),
                              children: [
                                ListTile(
                                  title: Text(spName),
                                  onTap: () => _showConfirmationDialog(spName, spId),
                                ),
                                ...?shreniPramukhGatanayaks[spId]?.map((gk) => ListTile(
                                  title: Text("${gk['first_name']} ${gk['last_name']}"),
                                  onTap: () => _showConfirmationDialog("${gk['first_name']} ${gk['last_name']}", gk['id']),
                                )),
                              ],
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(String userName, String userId) {
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
                Navigator.of(context).pop(); // Close selector
                _migrateSelectedInfluencers(userId);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}

