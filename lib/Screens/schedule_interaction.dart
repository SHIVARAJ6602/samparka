import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Service/api_service.dart';

class AddInteractionPage extends StatefulWidget {
  final String id; // Interaction ID passed from previous screen

  const AddInteractionPage(this.id, {super.key});

  @override
  AddInteractionPageState createState() => AddInteractionPageState();
}

class AddInteractionPageState extends State<AddInteractionPage> {
  final apiService = ApiService();

  // Controllers
  final TextEditingController discussionPointsController = TextEditingController();
  final TextEditingController actionPointsController = TextEditingController();
  final TextEditingController materialsDistributedController = TextEditingController();

  // Dropdown values
  final List<String> meetTypes = [
    'Routine Samparka (Regular Connect)',
    'Invitation Meeting',
    'Accidental / Chance Meeting',
    'Follow-up Meeting',
    'Special Purpose Meeting',
    'Others'
  ];
  String selectedMeetType = 'Routine Samparka (Regular Connect)';

  final List<String> locationTypes = [
    'Home / Residence',
    'Office / Workplace',
    'Event / Function Venue',
    'Public Place / Hotel'
  ];
  String selectedLocationType = 'Home / Residence';

  // Dates
  DateTime? selectedMeetDate;

  @override
  void initState() {
    super.initState();
    selectedMeetDate = DateTime.now(); // default today's date
  }

  /// Select date (no time picker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMeetDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedMeetDate = picked;
      });
    }
  }

  /// API call with validation
  Future<void> _saveInteraction() async {
    if (discussionPointsController.text.trim().isEmpty ||
        actionPointsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Discussion and Action Points'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final interactionData = {
      "title": selectedMeetType,
      "locationType": selectedLocationType,
      "meetingDate": selectedMeetDate?.toIso8601String(),
      "discussionPoints": discussionPointsController.text.trim(),
      "actionPoints": actionPointsController.text.trim(),
      "materialsDistributed": materialsDistributedController.text.trim(),
      "ganyavyaktiId": widget.id
    };

    final success = await apiService.createInteraction(interactionData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interaction Saved'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save interaction, please try later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    discussionPointsController.dispose();
    actionPointsController.dispose();
    materialsDistributedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add Meeting",
          style: TextStyle(color: Color.fromRGBO(5, 50, 70, 1.0)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting Type
            _buildDropdown(
              value: selectedMeetType,
              items: meetTypes,
              onChanged: (val) => setState(() => selectedMeetType = val!),
              hint: 'Meeting Type',
            ),
            const SizedBox(height: 10),

            // Location & Date row
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: selectedLocationType,
                    items: locationTypes,
                    onChanged: (val) => setState(() => selectedLocationType = val!),
                    hint: 'Location Type',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDatePickerButton(normFontSize, context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Discussion points
            _buildMultiLineField(
              controller: discussionPointsController,
              hint: 'Discussion Points',
              minLines: 5,
            ),
            const SizedBox(height: 10),

            // Action points
            _buildMultiLineField(
              controller: actionPointsController,
              hint: 'Action Points',
              minLines: 3,
            ),
            const SizedBox(height: 16),

            // Materials given
            _buildTextField(
              controller: materialsDistributedController,
              hint: "Books / Materials Given",
            ),
            const SizedBox(height: 20),

            // Save button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Common dropdown builder
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade400, width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(item),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Common text field
  Widget _buildTextField({required String hint, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(hint),
    );
  }

  /// Common multiline text field
  Widget _buildMultiLineField({
    required String hint,
    required TextEditingController controller,
    int minLines = 3,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: null,
      decoration: _inputDecoration(hint),
    );
  }

  /// Input Decoration
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
    );
  }

  /// Date picker button
  Widget _buildDatePickerButton(double fontSize, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: TextButton(
        onPressed: () => _selectDate(context),
        style: TextButton.styleFrom(padding: const EdgeInsets.all(12)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              selectedMeetDate == null
                  ? "Select Date"
                  : "${selectedMeetDate!.toLocal()}".split(' ')[0],
              style: TextStyle(color: Colors.grey.shade600, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }

  /// Save button
  Widget _buildSaveButton() {
    return Container(
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
        onPressed: _saveInteraction,
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Save',
              style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.check_circle, color: Colors.white)
          ],
        ),
      ),
    );
  }
}
