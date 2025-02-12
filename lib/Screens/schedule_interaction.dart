import 'package:flutter/material.dart';

import '../Service/api_service.dart';

class AddInteractionPage extends StatefulWidget {
  final String id;

  // Receiving the id directly through the constructor
  AddInteractionPage(this.id);

  @override
  _AddInteractionPageState createState() => _AddInteractionPageState();
}

class _AddInteractionPageState extends State<AddInteractionPage> {

  final apiService = ApiService();

  final TextEditingController summaryDataController = TextEditingController();
  final TextEditingController titleDataController = TextEditingController();
  final TextEditingController placeDataController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController materials_distributedController = TextEditingController();
  final TextEditingController virtual_meeting_linkController = TextEditingController();
  final TextEditingController discussion_pointsController = TextEditingController();
  //final TextEditingController discussion_pointsDataController = TextEditingController();
  //final TextEditingController action_pointsDataController = TextEditingController();


  List<String> status = ['scheduled', 'completed', 'cancelled'];

  DateTime? selectedDate;
  DateTime? selectedMeetDate;
  String? selectedStatus = 'scheduled';


  // Function to show the DatePicker and update the selected date
  Future<void> _selectDateTime(BuildContext context, bool isFromDate) async {
    final DateTime initialDate = DateTime.now();
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime(2101);

    // Pick date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      // Pick time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        setState(() {
          // Combine selected date and time
          selectedMeetDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          print(selectedMeetDate);
        });
      }
    }
  }

  // Function to show the DatePicker and update the selected date
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime initialDate = DateTime.now();
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime(2101);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null && picked != initialDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void createInteraction(){
    List<dynamic> interactionData = [
      titleDataController.text, // 0: Meeting Title
      placeDataController.text, // 1: Meeting Place
      selectedMeetDate?.toIso8601String(), // 2: Meeting Date
      selectedStatus, // 3: Meeting Status
      descriptionController.text, // 4: Description
      materials_distributedController.text, // 5: Materials Distributed
      virtual_meeting_linkController.text, // 6: Virtual Meeting Link
      discussion_pointsController.text,//7
      widget.id, // 8: Interaction ID (or widget ID)
    ];
    apiService.createInteraction(interactionData);

  }


  @override
  Widget build(BuildContext context) {
    print(widget.id);
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
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
                            "Schedule or Create Meeting",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(5, 50, 70, 1.0),
                            ),
                          ),
                          SizedBox(height: 30),

                          _buildTextField(hint: "Meeting Title", controller: titleDataController),

                          SizedBox(height: 16),
                          TextField(
                            controller: descriptionController,
                            maxLines: null,
                            minLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Meeting Description',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400, // Light grey when not focused
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(hint: "Location", controller: placeDataController),
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
                                  child: TextButton(
                                    onPressed: () => _selectDateTime(context, true),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(12), // Remove default padding of TextButton
                                    ),
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
                                          style: TextStyle(color: Colors.grey.shade600,fontSize: normFontSize),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: discussion_pointsController,
                            maxLines: null,
                            minLines: 5,
                            decoration: InputDecoration(
                              hintText: 'note any discussion points.',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400, // Light grey when not focused
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildTextField(hint: "Virtual Meeting Link", controller: virtual_meeting_linkController),
                          SizedBox(height: 16),
                          _buildTextField(hint: "Materials Distributed", controller: materials_distributedController),
                          SizedBox(height: 16),
                          //status
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade400, width: 1.0),
                            ),
                            child: DropdownButton<String>(
                              hint: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('Scheduled'),
                              ),
                              value: selectedStatus,
                              onChanged: (String? newState) {
                                setState(() {
                                  selectedStatus = newState;
                                });
                                print(selectedStatus);
                              },
                              items: status.map<DropdownMenuItem<String>>((state) {
                                return DropdownMenuItem<String>(
                                  value: state,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(state),
                                  ),
                                );
                              }).toList(),
                              isExpanded: true,
                              underline: Container(),
                            ),
                          ),
                          SizedBox(height: 10),
                          // Submit Button
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color.fromRGBO(2, 40, 60, 1),
                                    Color.fromRGBO(60, 170, 145, 1.0),
                                  ],
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  createInteraction();
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Submit',
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

  Widget _buildTextField({required String hint, required TextEditingController controller}) {
    return TextField(
      controller: controller, // Assign the dynamic controller
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