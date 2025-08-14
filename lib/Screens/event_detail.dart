import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:samparka/Screens/view_meeting.dart';
import '../Service/api_service.dart';
import '../widgets/influencer_card.dart';
//import '../widgets/member_card.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  final String meetingTypeId;

  const EventDetailPage({
    super.key,
    required this.eventId,
    required this.meetingTypeId,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? eventData;
  List<dynamic> images = [];
  List<String> status = ['scheduled', 'completed', 'cancelled'];

  DateTime? selectedDate;
  DateTime? selectedMeetDate;
  String? selectedStatus = 'scheduled';
  //late List<dynamic> result;
  late List<dynamic> interaction = [];
  late List<dynamic> ganyavyakthis = [];
  late List<dynamic> karyakartha = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final result = await apiService.getEventByID(widget.eventId, widget.meetingTypeId);
      if (result.isNotEmpty) {
        setState(() {
          eventData = result[0];
        });
      }

      final imageResult =
      await apiService.getEventImages(widget.eventId, widget.meetingTypeId);
      if(eventData?['ganyavyakti'] != null){
        if(eventData?['ganyavyakti'].isNotEmpty){
          fetchGanyavyakthi(eventData?['ganyavyakti']);
        }
      }
      selectedStatus = eventData?['status'];
      if (eventData?['participants'] != null && eventData?['participants'].isNotEmpty) {
        fetchKaryakartha(eventData?['participants']);
      }
      setState(() {
        images = imageResult;
        loading = false;
      });
    } catch (e) {
      log("Error loading event: $e");
      setState(() => loading = false);
    }
  }

  Future<bool> fetchGanyavyakthi(List<dynamic> gvIds) async {
    try {
      for (var gv in gvIds) {  // Corrected loop syntax
        var result = await apiService.getGanyavyakthi(gv);
        if (result[0]['soochi'] == 'AkhilaBharthiya') {
          result[0]['soochi'] = 'AB';
        } else if (result[0]['soochi'] == 'PranthyaSampark') {
          result[0]['soochi'] = 'PS';
        } else if (result[0]['soochi'] == 'JillaSampark') {
          result[0]['soochi'] = 'JS';
        }
        if (result[0]['interaction_level'] == 'Sampark') {
          result[0]['interaction_level'] = 'S1';
        } else if (result[0]['interaction_level'] == 'Sahavas') {
          result[0]['interaction_level'] = 'S2';
        } else if (result[0]['interaction_level'] == 'Samarthan') {
          result[0]['interaction_level'] = 'S3';
        } else if (result[0]['interaction_level'] == 'Sahabhag') {
          result[0]['interaction_level'] = 'S4';
        }// Call your service
        ganyavyakthis.add(result);
      }
      setState(() {
        // Trigger a UI update (this might be inside a StatefulWidget)
      });
      return true;
    } catch (e) {
      log("Error fetching interaction: $e");
    }
    return false;
  }

  Future<bool> fetchKaryakartha(List<dynamic> krIds) async {
    try {
      for (var kr in krIds) {  // Corrected loop syntax
        var result = await apiService.getKaryakartha(kr);  // Call your service
        karyakartha.add(result);
      }
      setState(() {

      });
      return true;
    } catch (e) {
      log("Error fetching interaction: $e");
    }
    return false;
  }


  void _openFullScreenGallery(BuildContext context, List imageList, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FullScreenImageGallery(
              imageList: imageList,
              initialIndex: initialIndex,
            ),
      ),
    );
  }
  void _openFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          body: Center(
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize + 4; //20
    double smallFontSize = normFontSize - 2; //14
    smallFontSize = smallFontSize;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
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
                            'Title: ${eventData?['title']}',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        //detail container
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
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
                                child: Text(
                                  'Description:\n          ${eventData?['description']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Place: ${eventData?['venue']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Date & Time: ${eventData?['meeting_datetime'] == null
                                      ? "Date & Time not set"
                                      : DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.parse(eventData?['meeting_datetime']).toLocal())}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: eventData?['meeting_datetime'] == null ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Status: ${selectedStatus ?? "Scheduled"}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: selectedStatus == null ? Colors.orange : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        //meet Images
                        if(images.isNotEmpty)
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              ...List.generate(images[0]['images'].length, (index) {
                                final imageUrl = images[0]['images'][index]['image_url'];
                                return GestureDetector(
                                  onTap: () => _openFullScreenGallery(context, images[0]['images'], index),
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width * 0.80) / 3,
                                    height: (MediaQuery.of(context).size.width * 0.80) / 3 + 15,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: (images.isNotEmpty &&
                                          images[0]['images'][index]['image'] != null &&
                                          images[0]['images'][index]['image'].isNotEmpty)
                                          ? Image.network(
                                        Uri.encodeFull(imageUrl),
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  (loadingProgress.expectedTotalBytes ?? 1)
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.white,
                                            child: Center(
                                              child: Icon(Icons.error, color: Colors.grey),
                                            ),
                                          );
                                        },
                                      )
                                          : Container(color: Colors.grey[200]),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),


                        if(ganyavyakthis.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10,),
                              Text('Influencers Attended:',style: TextStyle(fontSize: largeFontSize+5,fontWeight: FontWeight.bold),),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(60, 170, 145, 1.0),
                                      Color.fromRGBO(2, 40, 60, 1),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // If the list is empty, show a message
                                    if (ganyavyakthis.isNotEmpty)
                                      Column(
                                        children: List.generate(
                                          (ganyavyakthis.length < 4) ? ganyavyakthis.length : 3, // Display either all members or just 3
                                              (index) {
                                            final influencer = ganyavyakthis[index]; // Access the member data
                                            return Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10, top: 10,bottom: 10),
                                              child: InfluencerCard(
                                                id: influencer[0]['id']!,
                                                name: influencer[0]['fname']??'',
                                                designation: influencer[0]['designation']!,
                                                description: influencer[0]['description']??'',
                                                hashtags: '',
                                                //hashtags: influencer[0]['hashtags']??'',
                                                soochi: influencer[0]['soochi']??'',
                                                shreni: influencer[0]['shreni']??'',
                                                itrLvl: influencer[0]['interaction_level']??'',
                                                profileImage: influencer[0]['profile_image'] != null && influencer[0]['profile_image']!.isNotEmpty
                                                    ? apiService.baseUrl.substring(0,40)+influencer[0]['profile_image']!
                                                    : '',
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10,),
                            ],
                          ),

                        if(karyakartha.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10,),
                              Text('Karyakartha\'s Participated:',style: TextStyle(fontSize: largeFontSize+5,fontWeight: FontWeight.bold),),
                              Container(
                                decoration: BoxDecoration(
                                  //borderRadius: BorderRadius.circular(30),
                                  borderRadius: karyakartha.isEmpty ? BorderRadius.circular(10) : BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(60, 170, 145, 1.0),
                                      Color.fromRGBO(2, 40, 60, 1),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    // If the list is empty, show a message
                                    if (karyakartha.isEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'No Members Assigned',
                                            style: TextStyle(
                                              fontSize: largeFontSize,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    // If the list is not empty, build a ListView of InfluencerCards
                                    else
                                      Column(
                                        children: List.generate(
                                          (karyakartha.length < 4) ? karyakartha.length : 3, // Display either all members or just 3
                                              (index) {
                                            final member = karyakartha[index]; // Access the member data
                                            return Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10, top: 10,bottom: 10),
                                              child: MemberCard(
                                                id: member[0]['id']!,
                                                firstName: member[0]['first_name']!,
                                                lastName: member[0]['last_name']!,
                                                designation: member[0]['designation']??'',
                                                profileImage: member[0]['profile_image'] != null && member[0]['profile_image']!.isNotEmpty
                                                    ? member[0]['profile_image']!
                                                    : '',
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10,),
                            ],
                          )
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
}
