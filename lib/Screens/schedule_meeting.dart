import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';// Import multi_select_flutter package
import '../Service/api_service.dart';

class ScheduleMeetingPage extends StatefulWidget {
  const ScheduleMeetingPage({super.key});

  @override
  _ScheduleMeetingPageState createState() => _ScheduleMeetingPageState();
}

class _ScheduleMeetingPageState extends State<ScheduleMeetingPage> {

  final apiService = ApiService();
  final TextEditingController meetingTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final typeList = [{'id': 1, 'name': 'Baitak'}, {'id': 2,'name': 'Meeting'}];
  String? selectedType;
  String? selectedStatus = 'None';

  List<String> selectedMembersIds = []; // Change this to a list for multiple selection
  List<String> selectedInfluencerIds = []; // Change this to a list for multiple selection

  late List<dynamic> resultMem;
  late List<dynamic> resultInf;
  DateTime? selectedMeetDate;
  List<dynamic> members = [];
  List<dynamic> influencers = [];

  void createMeeting(){
    List<dynamic> MeetingData = [
      selectedType, // 0: The type of the meeting (e.g., business, casual, etc.)
      meetingTitleController.text, // 1: The title of the meeting, entered by the user
      descriptionController.text, // 2: Description of the meeting, entered by the user
      locationController.text, // 3: The location of the meeting, entered by the user
      selectedMeetDate?.toIso8601String(), // 4: The meeting date in ISO 8601 format, selected by the user
      selectedMembersIds, // 5: A list of selected member IDs who will attend the meeting
      selectedInfluencerIds, // 6: A list of selected influencer IDs relevant to the meeting
      selectedStatus, // 7: The current status of the meeting (e.g., scheduled, canceled, etc.)
      apiService.UserId, // 8: The User ID of the person organizing the meeting (e.g., interaction ID or widget ID)
    ];
    apiService.createMeeting(MeetingData);

  }

  Future<void> fetchMembers() async {
    try {
      resultMem = await apiService.myTeam(0, 100);
      if (resultMem.isEmpty) {
        setState(() {
          selectedMembersIds = [apiService.UserId]; // Default to self if no members are found
        });
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
      resultMem.add({'id': apiService.UserId, 'first_name': 'self(${apiService.first_name})', 'last_name': ''});
      setState(() {
        members = resultMem;
      });
    } catch (e) {
      print("Error fetching members: $e");
    }
  }

  Future<void> fetchInfluencers() async {
    try {
      resultInf = await apiService.myInfluencer(0, 100);
      setState(() {
        members = resultInf;
      });
    } catch (e) {
      print("Error fetching members: $e");
    }
  }

  // Function to show the multi-select dialog
  Future<void> _selectMembers(BuildContext context) async {
    final selectedMembers = await showDialog<List<dynamic>>(
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

    if (selectedMembers != null) {
      setState(() {
        selectedMembersIds = selectedMembers.cast<String>();
      });
    }
  }

  // Function to show the DatePicker and update the selected date
  Future<void> _selectDateTime(BuildContext context, bool isFromDate) async {
    final DateTime initialDate = DateTime.now();
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime(2101);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
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
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;
    double largeFontSize = normFontSize + 4;
    double smallFontSize = normFontSize - 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Meeting'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Schedule New", style: TextStyle(fontSize: normFontSize + 2, fontWeight: FontWeight.w600, color: const Color.fromRGBO(5, 50, 70, 1.0))),
                                Text("Meeting", style: TextStyle(fontSize: largeFontSize + 20, fontWeight: FontWeight.w600, color: const Color.fromRGBO(5, 50, 70, 1.0))),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  child: DropdownButton<String>(
                                    hint: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(typeList.isNotEmpty ? 'Select Meeting Type' : 'Loading Meeting Type..'),
                                    ),
                                    value: selectedType,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        print(newValue);
                                        selectedType = newValue;
                                      });
                                    },
                                    items: typeList.map<DropdownMenuItem<String>>((titles) {
                                      return DropdownMenuItem<String>(
                                        value: titles['id'].toString(),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Text('${titles['name']}'),
                                        ),
                                      );
                                    }).toList(),
                                    isExpanded: true,
                                    underline: Container(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(hint: "Meeting Title", controller: meetingTitleController),
                                const SizedBox(height: 16),
                                _buildTextField(hint: "Description", controller: descriptionController),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey.shade400, width: 1),
                                        ),
                                        child: TextButton(
                                          onPressed: () => _selectDateTime(context, true),
                                          style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
                                          child: Row(
                                            children: [
                                              Icon(Icons.calendar_today, color: Colors.grey.shade600),
                                              const SizedBox(width: 8),
                                              Text(
                                                selectedMeetDate == null
                                                    ? "Date & Time"
                                                    : "${selectedMeetDate!.toLocal()}".split(' ')[0],
                                                style: TextStyle(color: Colors.grey.shade600, fontSize: normFontSize),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextField(hint: "Location", controller: locationController)),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey.shade400, width: 1.0),
                                  ),
                                  child: InkWell(
                                    onTap: () => _selectMembers(context),
                                    borderRadius: BorderRadius.circular(15),  // Ensure the ripple effect respects the border radius
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Icon(Icons.person_add, color: Colors.grey.shade600),
                                          const SizedBox(width: 8),
                                          Text(
                                            selectedMembersIds.isEmpty
                                                ? "Select Members"
                                                : selectedMembersIds.join(', '),
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: normFontSize),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if(selectedType == '2')
                                  SizedBox(height: 16),
                                if (selectedType == '2')
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.grey.shade400, width: 1.0),
                                    ),
                                    child: InkWell(
                                      onTap: () => _selectMembers(context),
                                      borderRadius: BorderRadius.circular(15),  // Ensure the ripple effect respects the border radius
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.person_add, color: Colors.grey.shade600),
                                            const SizedBox(width: 8),
                                            Text(
                                              selectedInfluencerIds.isEmpty
                                                  ? "Select Influencers"
                                                  : selectedInfluencerIds.join(', '),
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: normFontSize),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                SizedBox(height: 16),
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
                                    onPressed: () async {
                                      createMeeting();
                                    },
                                    style: TextButton.styleFrom(padding: const EdgeInsets.all(10)),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Schedule Meeting',
                                            style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),
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
                                ),
                                SizedBox(height: 25),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint, required TextEditingController controller}) {
    return TextField(
      controller: controller,
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
