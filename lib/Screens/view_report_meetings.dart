import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:samparka/Screens/submit_report.dart';
import 'package:samparka/Screens/view_interaction.dart';
import 'package:samparka/Screens/view_meeting.dart';

import '../Service/api_service.dart';

class ViewReportMeetingsPage extends StatefulWidget {

  final String type;
  final String fromDate;
  final String toDate;

  const ViewReportMeetingsPage( this.type, this.fromDate, this.toDate, {super.key});

  @override
  _ViewReportMeetingsPageState createState() => _ViewReportMeetingsPageState();
}

class _ViewReportMeetingsPageState extends State<ViewReportMeetingsPage> {
  final apiService = ApiService();

  List<dynamic> meets = [];
  late List<dynamic> result;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMeets(widget.type,widget.fromDate,widget.toDate);
    loading = false;
  }

  // Define a function to fetch data
  Future<void> fetchMeets(meetType,fromDate,toDate) async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getReportMeet(meetType,fromDate,toDate);
      print(result);
      setState(() {
        meets = result;
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching Meetings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        title: Text('Events'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: List.generate(meets.length, (index) {
            final meeting = meets[index]; // Access the meeting data for each item
            return Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 12),
              child: MeetingCard(
                title: meeting['title']!,
                typeId: '1',
                description: meeting['description']!,
                dateTime: meeting['meeting_datetime']!,
                id: meeting['id']!,
                data: meeting,
              ),
            );
          }),
        ),
      )
    );
  }
}

/*
class MeetingCard extends StatelessWidget {
  final String type;
  final String id;
  final String title;
  final Map<String, dynamic> data;

  const MeetingCard({
    super.key,
    required this.title,
    required this.id,
    required this.data, required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(0), // Container padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextButton(
            onPressed: () {
              if(type != 'individual'){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewEventPage(id,data)),
                );
              }
              else{
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewInteractionPage(id)),
                );
              }
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              )),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 0,right: 0,bottom: 8,top: 8), // Add padding to the content
              child: Row(
                children: [
                  // Influencer Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title, // Dynamic name
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(5, 50, 70, 1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
*/
class MeetingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  final String typeId;
  final String description;
  final String dateTime;
  final String id;

  const MeetingCard({
    super.key,
    required this.title,
    required this.description,
    required this.id,
    required this.dateTime,
    required this.data, required this.typeId,
  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; // 16
    double largeFontSize = normFontSize + 4; // 20
    double smallFontSize = normFontSize - 2;

    String formatDate(String isoDateTime) {
      try {
        DateTime dateTimeObj = DateTime.parse(isoDateTime);
        return DateFormat('dd MMM yyyy').format(dateTimeObj);
      } catch (e) {
        return 'Invalid Date';
      }
    }

    String formatTime(String isoDateTime) {
      try {
        DateTime dateTimeObj = DateTime.parse(isoDateTime);
        return DateFormat('hh:mm a').format(dateTimeObj);  // Fixed time format
      } catch (e) {
        return 'Invalid Date';
      }
    }

    print(data['status']);

    Widget buildLabelValueRow(String label, String value) {
      return Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: smallFontSize,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: smallFontSize,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width * 0.95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Color.fromRGBO(60, 170, 145, 1.0),
            Color.fromRGBO(2, 40, 60, 1),
          ],
        ),
      ),
      child: TextButton(
        onPressed: () {
          if (id.startsWith('ir') || id.startsWith('IR')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewInteractionPage(id)),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewEventPage(id, data, typeId)),
            );
          }
        },

        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 1.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Column: Meeting details
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double screenWidth = MediaQuery.of(context).size.width;
                        double maxTextWidth = screenWidth * 0.80;

                        double fontSize = 26;
                        double estimatedTextWidth = title.length * largeFontSize;

                        if (estimatedTextWidth > maxTextWidth) {
                          fontSize = 20;
                        }

                        return Container(
                          width: maxTextWidth,
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        );
                      },
                    ),

                    buildLabelValueRow('Date', formatDate(dateTime)),
                    buildLabelValueRow('Time', formatTime(dateTime)),
                    buildLabelValueRow('Location', data['venue'] ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

