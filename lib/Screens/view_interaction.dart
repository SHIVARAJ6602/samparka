import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../Service/api_service.dart';

class ViewInteractionPage extends StatefulWidget {
  final String id;

  // Receiving the id directly through the constructor
  const ViewInteractionPage(this.id, {super.key});

  @override
  _ViewInteractionPageState createState() => _ViewInteractionPageState();
}

class _ViewInteractionPageState extends State<ViewInteractionPage> {

  final ApiService apiService = ApiService();

  // These controllers can be replaced with the meeting data from your API or passed data
  final TextEditingController summaryDataController = TextEditingController();
  final TextEditingController titleDataController = TextEditingController();
  final TextEditingController placeDataController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController materials_distributedController = TextEditingController();
  final TextEditingController virtual_meeting_linkController = TextEditingController();
  final TextEditingController discussion_pointsController = TextEditingController();

  List<String> status = ['scheduled', 'completed', 'cancelled'];

  DateTime? selectedDate;
  DateTime? selectedMeetDate;
  String? selectedStatus = 'scheduled';
  //late List<dynamic> result;
  late List<dynamic> Interaction = [];

  @override
  void initState() {
    super.initState();
    //print('id : ${widget.id} - view interaction');
    fetchInteraction(widget.id);
    /*titleDataController.text = Interaction[0]['title']??'';
    placeDataController.text = Interaction[0]['meeting_place']??'';
    selectedMeetDate = DateTime.parse(Interaction[0]['meeting_datetime']??'');
    selectedStatus = Interaction[0]['status'];
    descriptionController.text = Interaction[0]['description'];
    materials_distributedController.text = Interaction[0]['materials_distributed']??'';
    virtual_meeting_linkController.text = 'virtualLink'??'';
    discussion_pointsController.text = 'discussionPoints';*/
    //print(apiService.getInteractionByID(widget.id));
  }

  Future<bool> fetchInteraction(MT_id)async{
    try{
      var result = await apiService.getInteractionByID(MT_id);
      setState(() {
        print('fetch itr start');
        Interaction = result;
        titleDataController.text = Interaction[0]['title']??'';
        placeDataController.text = Interaction[0]['meeting_place']??'';
        //selectedMeetDate = DateTime.parse(Interaction[0]['meeting_datetime']??'1970-01-01T00:00:00Z');
        selectedMeetDate = DateTime.tryParse(Interaction[0]['meeting_datetime'] ?? '1970-01-01T00:00:00Z');
        //selectedMeetDate = DateFormat('yyyy-MM-dd HH:mm a').format(DateTime.parse(Interaction[0]['meeting_datetime'] ?? '1970-01-01T00:00:00Z'));;
        selectedStatus = Interaction[0]['status'];
        print('fetch itr mid');
        descriptionController.text = Interaction[0]['description'];
        materials_distributedController.text = Interaction[0]['materials_distributed']??'';
        virtual_meeting_linkController.text = 'virtualLink'??'';
        discussion_pointsController.text = Interaction[0]['discussion_points'];
        print("interaction : $Interaction");
      });
      setState(() {

      });
      return true;
    } catch (e) {
      print("Error fetching interaction: $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize + 4; //20
    double smallFontSize = normFontSize - 2; //14

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Title: ${titleDataController.text}',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            //color: Color.fromRGBO(255, 255, 255, 0.1), // Background color
                            borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                            border: Border.all(
                              color: Colors.grey.shade400, // Border color
                              width: 1, // Border width
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,  // Ensure text aligns to the left
                                    children: [
                                      Text(
                                        'Description:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: largeFontSize,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        descriptionController.text.trim(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: normFontSize,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Place: ${placeDataController.text}',
                                    style: TextStyle(
                                      fontSize: normFontSize,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Date & Time: ${selectedMeetDate == null
                                        ? "Date & Time not set"
                                        : DateFormat('yyyy-MM-dd hh:mm a').format(selectedMeetDate!.toLocal())}',
                                    style: TextStyle(
                                      fontSize: normFontSize,
                                      color: selectedMeetDate == null ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Discussion Points:\n ${discussion_pointsController.text}',
                                    style: TextStyle(
                                      fontSize: normFontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Materials Given:\n ${materials_distributedController.text}',
                                    style: TextStyle(
                                      fontSize: normFontSize,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Status: ${selectedStatus ?? "Scheduled"}',
                                    style: TextStyle(
                                      fontSize: normFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: selectedStatus == null ? Colors.orange : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                          ),
                        ),
                        /*
                        _buildReadOnlyField("Meeting Title", titleDataController),

                        SizedBox(height: 16),
                        _buildReadOnlyField("Meeting Description", descriptionController),

                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildReadOnlyField("Location", placeDataController),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // Background color
                                  borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                                  border: Border.all(
                                    color: Colors.grey.shade400, // Border color
                                    width: 1, // Border width
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12), // Padding inside the container
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey.shade600,
                                      ),
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
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildReadOnlyField("Discussion Points", discussion_pointsController),
                        SizedBox(height: 16),
                        _buildReadOnlyField("Virtual Meeting Link", virtual_meeting_linkController),
                        SizedBox(height: 16),
                        _buildReadOnlyField("Materials Distributed", materials_distributedController),
                        SizedBox(height: 16),
                        // Display the status dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade400, width: 1.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              selectedStatus ?? "Scheduled",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: normFontSize),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),*/
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.shade400, // Set the grey border color
            width: 1.0,  // Set the border width
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.shade600, // Darker grey when focused
            width: 1.5, // Slightly thicker border when focused
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.shade400, // Light grey when not focused
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
