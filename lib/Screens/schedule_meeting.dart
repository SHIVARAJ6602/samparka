import 'package:flutter/material.dart';

class ScheduleMeetingPage extends StatefulWidget {
  const ScheduleMeetingPage({super.key});

  @override
  _ScheduleMeetingPageState createState() => _ScheduleMeetingPageState();
}

class _ScheduleMeetingPageState extends State<ScheduleMeetingPage> {

  final TextEditingController meetingTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final typeList = [{'id': 1, 'name': 'Baitek'}, {'id': 2,'name': 'Meeting'}];
  String? selectedType;

  DateTime? selectedMeetDate;


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




  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Meeting'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // + New Title
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Schedule New",
                                style: TextStyle(
                                  fontSize: normFontSize+2,
                                  fontWeight: FontWeight.w600,
                                  color: const Color.fromRGBO(5, 50, 70, 1.0),
                                ),
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                "Meeting",
                                style: TextStyle(
                                  fontSize: largeFontSize+20,
                                  fontWeight: FontWeight.w600,
                                  color: const Color.fromRGBO(5, 50, 70, 1.0),
                                ),
                              ),
                              // meeting Type
                              const SizedBox(height: 16),
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
                                    child: Text(typeList.isNotEmpty ? 'Select Meeting Type' : 'Loading Meeting Typr..'),
                                  ),
                                  value: selectedType,
                                  onChanged: (String? newValue) {
                                    setState(() {
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
                                  isExpanded: true, // Ensures the dropdown stretches to the full width
                                  underline: Container(), // Removes the default underline from the dropdown
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildTextField(hint: "Location", controller: locationController),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),




                              // schedule Button
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
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 10), // Adjust padding
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,  // Center the row content
                                      children: [
                                        const Text(
                                          'Schedule Meeting',
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
                              SizedBox(height: 25),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildTextField({required String hint,required TextEditingController controller}) {
    return TextField(
      controller: controller,
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