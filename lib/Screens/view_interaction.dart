import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:samparka/widgets/loading_indicator.dart';
import '../Service/api_service.dart';

class ViewInteractionPage extends StatefulWidget {
  final String id;

  const ViewInteractionPage(this.id, {super.key});

  @override
  _ViewInteractionPageState createState() => _ViewInteractionPageState();
}

class _ViewInteractionPageState extends State<ViewInteractionPage> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? interaction;

  @override
  void initState() {
    super.initState();
    fetchInteraction(widget.id);
  }

  Future<void> fetchInteraction(String mtId) async {
    try {
      var result = await apiService.getInteractionByID(mtId);
      if (result.isNotEmpty) {
        setState(() {
          interaction = result[0];
        });
      }
    } catch (e) {
      log("Error fetching interaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;
    double largeFontSize = normFontSize + 4;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: interaction == null
          ? const Center(child: LoadingIndicatorGreen())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title - bold
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                interaction!['title'] ?? 'No Title',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Main Container (same old style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discussion Points at top
                  Text(
                    "Discussion Points:",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: largeFontSize,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    interaction!['discussion_points']?.toString().trim() ??
                        'No discussion points',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: normFontSize,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 8,),
                  // Action Points
                  Text(
                    "Action Points:",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: largeFontSize,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    interaction!['action_points'] ?? 'No action points',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: normFontSize,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 8,),
                  // Materials
                  Text(
                    "Materials Given:",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: largeFontSize,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    interaction!['materials_distributed'] ??
                        'No materials given',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: normFontSize,
                        color: Colors.black87),
                  ),

                  const Divider(height: 24),

                  // Place
                  Text(
                    "Place: ${interaction!['meeting_place'] ?? 'Not specified'}",
                    style: TextStyle(
                      fontSize: normFontSize,
                      fontStyle: FontStyle.italic,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date (only date)
                  Text(
                    "Date: ${_formatDate(interaction!['meeting_datetime'])}",
                    style: TextStyle(
                      fontSize: normFontSize,
                      color: interaction!['meeting_datetime'] == null
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'Date not set';
    }
    try {
      final parsedDate = DateTime.tryParse(dateTimeString);
      if (parsedDate == null) return 'Invalid Date';
      return DateFormat('yyyy-MM-dd').format(parsedDate.toLocal());
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
