import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';// Import multi_select_flutter package
import '../Service/api_service.dart';

class ScheduleMeetingPage extends StatefulWidget {
  const ScheduleMeetingPage({super.key});

  @override
  ScheduleMeetingPageState createState() => ScheduleMeetingPageState();
}

class ScheduleMeetingPageState extends State<ScheduleMeetingPage> {

  final apiService = ApiService();
  final TextEditingController meetingTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final typeList = [{'id': 1, 'name': 'Baitak'}, {'id': 2,'name': 'Program'}, {'id': 3, 'name':'SmallGroupEvent'}];
  String? selectedType = '1'; // Default to 'Baitak'
  String? selectedStatus = 'scheduled';

  List<String> selectedMembersIds = [];
  List<String> selectedInfluencerIds = [];

  late List<dynamic> resultMem;
  late List<dynamic> resultInf;
  DateTime? selectedMeetDate;
  List<dynamic> members = [];
  List<dynamic> influencers = [];

  Future<bool> createMeeting() async {
    List<dynamic> meetingData = [
      selectedType, 
      meetingTitleController.text, 
      descriptionController.text, 
      locationController.text, 
      selectedMeetDate?.toIso8601String(), 
      selectedMembersIds, 
      selectedInfluencerIds, 
      selectedStatus, 
      apiService.UserId, 
    ];
    if(await apiService.createMeeting(meetingData)){
      return true;
    } else {
      return false;
    }
  }

  Future<void> fetchMembers() async {
    try {
      resultMem = await apiService.myTeam(0, 100);
      if (!mounted) return;

      if (resultMem.isEmpty) {
        setState(() {
          selectedMembersIds = [apiService.UserId]; 
        });
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Alert'),
                content: Text('No members to assign. Defaulting to self: ${apiService.first_name}'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }

      resultMem.add({
        'id': apiService.UserId,
        'first_name': 'self(${apiService.first_name})',
        'last_name': '',
      });

      if (mounted) {
        setState(() {
          members = resultMem;
        });
      }
    } catch (e) {
      log("Error fetching members: $e");
    }
  }

  Future<void> fetchInfluencers() async {
    try {
      resultInf = await apiService.getInfluencer(0, 100,apiService.UserId);
      if (mounted) {
        setState(() {
          influencers = resultInf;
        });
      }
    } catch (e) {
      log("Error fetching influencers: $e"); // Corrected log message
    }
  }

  Future<void> _selectMembers(BuildContext context) async {
    final selectedItems = await showDialog<List<dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: members.map((member) {
            return MultiSelectItem(member['id'], '${member['first_name']} ${member['last_name']}');
          }).toList(),
          title: Text('Select Members'),
          initialValue: selectedMembersIds,
        );
      },
    );

    if (selectedItems != null) {
      setState(() {
        selectedMembersIds = selectedItems.cast<String>();
      });
    }
  }

  Future<void> _selectInfluencers(BuildContext context) async {
    final selectedItems = await showDialog<List<dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: influencers.map((inf) { // Changed 'member' to 'inf' for clarity
            return MultiSelectItem(inf['id'], '${inf['lname']} ${inf['fname']}');
          }).toList(),
          title: Text('Select Influencers'), // Corrected title
          initialValue: selectedInfluencerIds,
        );
      },
    );

    if (selectedItems != null) {
      setState(() {
        selectedInfluencerIds = selectedItems.cast<String>();
      });
    }
  }

  String getMemberName(String id, List<dynamic> membersList) { // Renamed 'members' to 'membersList' to avoid conflict
    final member = membersList.firstWhere(
          (m) => m['id'] == id,
      orElse: () => {'first_name': 'Unknown', 'last_name': 'Member'}, // Provide default map
    );
    return '${member['first_name']} ${member['last_name']}'.trim();
  }

  String getInfluencerName(String id, List<dynamic> influencersList) { // Renamed 'influencers' to 'influencersList'
    final influencer = influencersList.firstWhere(
          (inf) => inf['id'] == id,
      orElse: () => {'fname': 'Unknown', 'lname': 'Influencer'}, // Provide default map
    );
    return '${influencer['fname']} ${influencer['lname']}'.trim();
  }

  Future<void> _selectDateTime(BuildContext context) async { // Removed unused 'isFromDate'
    final DateTime initialDate = selectedMeetDate ?? DateTime.now();
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime(2101);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (!mounted || pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context, // Use the original context
      initialTime: TimeOfDay.fromDateTime(selectedMeetDate ?? initialDate),
    );

    if (!mounted || pickedTime == null) return;

    setState(() {
      selectedMeetDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMembers();
    fetchInfluencers();
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;
    double largeFontSize = normFontSize + 4;
    // double smallFontSize = normFontSize - 2; // Unused, commented out

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Use theme background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        //title: Text('Create Event', style: TextStyle(color: Theme.of(context).colorScheme.onBackground)), // Use theme color
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onBackground), // Use theme color for back button
      ),
      body: SingleChildScrollView( // Changed from Stack/Column/Expanded/SingleChildScrollView
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Schedule New", style: TextStyle(fontSize: normFontSize + 2, fontWeight: FontWeight.w600, color: Color.fromRGBO(5, 50, 70, 1.0))),
            Text("Event", style: TextStyle(fontSize: largeFontSize + 30, fontWeight: FontWeight.w600, color: Color.fromRGBO(5, 50, 70, 1.0))),
            const SizedBox(height: 24), // Increased spacing

            // Event Type Buttons
            Text("Event Type", style: TextStyle(fontSize: normFontSize, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0, // horizontal spacing between buttons
              runSpacing: 8.0, // vertical spacing if it wraps
              children: typeList.map<Widget>((type) {
                bool isSelected = selectedType == type['id'].toString();
                Color selectedColor = Color.fromRGBO(60, 170, 145, 1.0);
                Color defaultColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
                Color borderColor = isSelected ? selectedColor : Theme.of(context).dividerColor;

                return OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedType = type['id'].toString();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isSelected ? selectedColor : defaultColor,
                    side: BorderSide(
                      color: borderColor,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  child: Text(
                    type['name'].toString() == 'SmallGroupEvent'
                        ? 'Small Group Event'
                        : type['name'].toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: normFontSize - 1,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20), // Consistent spacing

            _buildTextField(hint: "Event Title", controller: meetingTitleController),
            const SizedBox(height: 16),
            _buildTextField(hint: "Description", controller: descriptionController, maxLines: 3), // Allow multiple lines for description
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeButton(context),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(hint: "Location", controller: locationController)),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMultiSelectButton(
              context: context,
              label: "Select Members",
              selectedIds: selectedMembersIds,
              namesGetter: (id) => getMemberName(id, members),
              onTap: () => _selectMembers(context),
            ),
            
            if (selectedType != '1') // Only show for Program and SmallGroupEvent
              const SizedBox(height: 16),
            if (selectedType != '1')
              _buildMultiSelectButton(
                context: context,
                label: "Select Influencers",
                selectedIds: selectedInfluencerIds,
                namesGetter: (id) => getInfluencerName(id, influencers),
                onTap: () => _selectInfluencers(context),
              ),
            const SizedBox(height: 24), // Increased spacing

            // Schedule Event Button
            Container(
              width: double.infinity, // Make button full width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // Adjusted radius
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
                onPressed: () async {
                  // Basic validation
                  if (meetingTitleController.text.isEmpty || selectedMeetDate == null || selectedMembersIds.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text('Please fill all required fields: Title, Date/Time, and Members.'),
                         backgroundColor: Colors.orange,
                       ),
                     );
                     return;
                  }
                  if (selectedType != '1' && selectedInfluencerIds.isEmpty){
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text('Please select influencers for Program or Small Group Event.'),
                         backgroundColor: Colors.orange,
                       ),
                     );
                     return;
                  }


                  final success = await createMeeting();
                  if (!mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Event Scheduled Successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, true); 
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to Schedule Event. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16), // Adjusted padding
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)) // Ensure shape matches decoration
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Schedule Event',
                      style: TextStyle(fontSize: largeFontSize -2 , color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Transform.rotate(
                      angle: 4.7124, // 270 degrees in radians
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
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeButton(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(12), // Consistent border radius
        border: Border.all(color: Theme.of(context).inputDecorationTheme.border?.borderSide.color ?? Colors.grey.shade400, width: 1),
      ),
      child: TextButton(
        onPressed: () => _selectDateTime(context),
        style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15), // Adjusted padding
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded( // Added Expanded to prevent overflow
              child: Text(
                selectedMeetDate == null
                    ? "Date & Time"
                    : "${selectedMeetDate!.toLocal().toIso8601String().substring(0, 16).replaceAll('T', ' ')}", // Formatted date and time
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: normFontSize),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectButton({
    required BuildContext context,
    required String label,
    required List<String> selectedIds,
    required String Function(String) namesGetter,
    required VoidCallback onTap,
  }) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;
    String displayText;
    if (selectedIds.isEmpty) {
      displayText = label;
    } else if (selectedIds.length <= 2) { // Show 1 or 2 names
      displayText = selectedIds.map(namesGetter).join(', ');
    } else {
      displayText = '${namesGetter(selectedIds[0])}, +${selectedIds.length - 1} more';
    }

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(12), // Consistent border radius
        border: Border.all(color: Theme.of(context).inputDecorationTheme.border?.borderSide.color ?? Colors.grey.shade400, width: 1.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12), // Adjusted padding
          child: Row(
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded( // Added Expanded to prevent overflow
                child: Text(
                  displayText,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: normFontSize),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required TextEditingController controller, int? maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
      ),
    );
  }
}
