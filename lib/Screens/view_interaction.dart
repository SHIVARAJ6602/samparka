import 'package:flutter/material.dart';

import '../Service/api_service.dart';

class ViewInteractionPage extends StatefulWidget {
  final String id;

  // Receiving the id directly through the constructor
  ViewInteractionPage(this.id);

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

  @override
  void initState() {
    super.initState();

    titleDataController.text = 'title';
    placeDataController.text = 'place';
    selectedMeetDate = DateTime.parse('2025-02-09T22:31:00.000');
    selectedStatus = 'status';
    descriptionController.text = 'description';
    materials_distributedController.text = 'materialsDistributed';
    virtual_meeting_linkController.text = 'virtualLink';
    discussion_pointsController.text = 'discussionPoints';
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize + 4; //20
    double smallFontSize = normFontSize - 2; //14

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Meeting Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(5, 50, 70, 1.0),
                          ),
                        ),
                        SizedBox(height: 30),

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
                        SizedBox(height: 20),
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
