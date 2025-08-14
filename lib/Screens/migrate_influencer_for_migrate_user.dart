import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Service/api_service.dart';
import '../widgets/influencer_card.dart';
import 'influencer_profile.dart';

class MigrateInfluencerForUserPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> karyakartha;

  const MigrateInfluencerForUserPage(this.userId, {super.key, required this.karyakartha});

  @override
  State<MigrateInfluencerForUserPage> createState() => _MigrateInfluencerForUserPageState();
}

class _MigrateInfluencerForUserPageState extends State<MigrateInfluencerForUserPage> {
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

  bool infFetched = false;
  bool _hasLoadedAllData = false;

  late Map<String, dynamic> karyakartha;
  List<dynamic> karyakarthaInfluencers = [];

  @override
  void initState() {
    super.initState();
    karyakartha = widget.karyakartha;
    _loadInfluencers();
  }

  Future<void> fetchHashtags() async {
    try {
      result = await apiService.getHashtags();
      setState(() => hashtags = result);
    } catch (e) {
      log("Error fetching hashtags: $e");
    }
  }

  Future<bool> _fetchData() async {
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
      return true;

    } catch (e) {
      log('Error loading data: $e');
      return false;
    }

    setState(() => loading = false);
  }

  Future<void> _loadInfluencers() async {
    try {
      hashtags = await apiService.getHashtags();
      karyakarthaInfluencers = await apiService.getInfluencer(1, 100, karyakartha['id']);
    } catch (e) {
      log('Error loading influencers: $e');
    }

    setState(() {
      infFetched = true;
    });
  }

  Future<void> _loadAllData() async {
    if (_hasLoadedAllData) return;

    // Show loading dialog first
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text("Loading Karyakartha"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "It may take some time to retrieve all Karyakartha.\n\n"
                    "Please wait and don’t close the page or press back.",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final loaded = await _fetchData();

      if (loaded) {
        _hasLoadedAllData = true;
        setState(() {});
      }
    } catch (e) {
      log("Error in _loadAllData: $e");
    } finally {
      // Always close the dialog
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _toggleInfluencerSelection(String id) {
    setState(() {
      selectedInfluencerIds.contains(id)
          ? selectedInfluencerIds.remove(id)
          : selectedInfluencerIds.add(id);
    });
  }

  void _migrateSelectedInfluencers(String targetUserId) async {
    if (selectedInfluencerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one influencer to migrate.")),
      );
      return;
    }

    await _loadAllData();

    try {
      final result = await apiService.migrateInfluencers(selectedInfluencerIds, targetUserId);
      final migrated = result['migrated'] ?? [];
      final failed = result['failed'] ?? [];

      await _loadInfluencers(); // refresh remaining influencers

      selectedInfluencerIds.clear();

      final bool allMigrated = karyakarthaInfluencers.isEmpty;

      if (allMigrated) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Migration Complete"),
            content: Text("${migrated.length} influencers migrated successfully."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // close dialog
                child: Text("OK"),
              ),
            ],
          ),
        ).then((_) => Navigator.of(context).pop(true)); // return true to caller
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Partial Migration"),
            content: Text(
              "${migrated.length} migrated.\n${failed.length} failed.\n"
                  "Some influencers are still under this Karyakartha.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // dismiss
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      log("Migration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Migration failed: $e")),
      );
    }
  }

  void _showMigrationTargetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Migration Target"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("My Account"),
              subtitle: Text(apiService.first_name),
              onTap: () {
                Navigator.of(context).pop();
                _migrateSelectedInfluencers(widget.userId);
              },
            ),
            // Add more user targets here
          ],
        ),
      ),
    );
  }

  void _returnWithoutTransfer() {
    Navigator.of(context).pop(false); // explicitly return false
  }

  @override
  Widget build(BuildContext context) {
    if (!infFetched) {
      return Scaffold(
        appBar: AppBar(title: Text("Migrate Influencers")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Migrate Influencers"),
        actions: [
          TextButton(
            onPressed: _returnWithoutTransfer,
            child: Text("Keep Karyakartha", style: TextStyle(color: Colors.redAccent)),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: karyakarthaInfluencers.isEmpty
            ? Center(child: Text("No influencers available."))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${karyakartha['first_name']} ${karyakartha['last_name']}",
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 10),
            Expanded(child: _buildInfluencerList()),
            SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showMigrationTargetDialog,
        label: Text("Migrate Selected"),
        icon: Icon(Icons.swap_horiz),
      ),
    );
  }

  Widget _buildInfluencerList() {
    return ListView.builder(
      itemCount: karyakarthaInfluencers.length,
      itemBuilder: (context, index) {
        final influencer = karyakarthaInfluencers[index];
        final id = influencer['id'];
        final fullName = "${influencer['fname']} ${influencer['lname']}";
        final isSelected = selectedInfluencerIds.contains(id);

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Stack(
            children: [
              AbsorbPointer(
                child: InfluencerCard(
                  id: id,
                  name: fullName,
                  designation: influencer['designation'] ?? '',
                  description: influencer['description'] ?? '',
                  hashtags: "", // You can fill hashtags here
                  soochi: influencer['soochi'] ?? '',
                  shreni: influencer['shreni'] ?? '',
                  itrLvl: influencer['interaction_level'] ?? '',
                  profileImage: influencer['profile_image'] ?? '',
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _toggleInfluencerSelection(id),
                  onLongPress: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => InfluencerProfilePage(id)),
                  ),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black.withOpacity(0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: isSelected
                        ? Center(child: Icon(Icons.check_circle, color: Colors.white, size: 32))
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
