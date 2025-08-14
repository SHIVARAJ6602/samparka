import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InteractionDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> interaction;

  const InteractionDetailsWidget({super.key, required this.interaction});

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041;
    double largeFontSize = normFontSize + 4;

    return Container(
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
          // Title inside the container
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              interaction['title'] ?? 'No Title',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Divider(height: 24),

          // Discussion Points
          Text(
            "Discussion Points:",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: largeFontSize,
              color: Colors.black87,
            ),
          ),
          Text(
            interaction['discussion_points']?.toString().trim() ??
                'No discussion points',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: normFontSize,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 24),

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
            interaction['action_points'] ?? 'No action points',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: normFontSize,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 24),

          // Place
          Text(
            "Place: ${interaction['meeting_place'] ?? 'Not specified'}",
            style: TextStyle(
              fontSize: normFontSize,
              fontStyle: FontStyle.italic,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 8),

          // Date
          Text(
            "Date: ${_formatDate(interaction['meeting_datetime'])}",
            style: TextStyle(
              fontSize: normFontSize,
              color: interaction['meeting_datetime'] == null
                  ? Colors.red
                  : Colors.green,
            ),
          ),
          const Divider(height: 24),

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
            interaction['materials_distributed'] ?? 'No materials given',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: normFontSize,
              color: Colors.black87,
            ),
          ),
        ],
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
