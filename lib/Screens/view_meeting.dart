import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../Service/api_service.dart';
import 'user_profile_page.dart';
import 'influencer_profile.dart';

class ViewEventPage extends StatefulWidget {
  final String id;
  final String type;
  final Map<String, dynamic> data;

  // Receiving the id directly through the constructor
  const ViewEventPage(this.id,this.data,this.type, {super.key});

  @override
  _ViewEventPageState createState() => _ViewEventPageState();
}

class _ViewEventPageState extends State<ViewEventPage> {

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
  late List<dynamic> images = [];
  late List<dynamic> Interaction = [];
  late List<dynamic> GanyaVyakthis = [];
  late List<dynamic> karyakartha = [];

  @override
  void initState() {
    super.initState();
    print('data = ${widget.data}');
    print(widget.data['meeting_datetime']);
    if(widget.data['ganyavyakti'] != null){
      if(widget.data['ganyavyakti'].isNotEmpty){
        print('GV = ${widget.data['ganyavyakti']}');
        fetchGanyavyakthi(widget.data['ganyavyakti']);
      }
    }

    if (widget.data['participants'] != null && widget.data['participants'].isNotEmpty) {
      fetchKaryakartha(widget.data['participants']);
    }

    fetchEventImages('1');

    //fetchEvent(widget.id);
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

  Future<bool> fetchGanyavyakthi(List<dynamic> GV_ids) async {
    try {
      for (var GV in GV_ids) {  // Corrected loop syntax
        var result = await apiService.getGanyavyakthi(GV);
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
        GanyaVyakthis.add(result);
      }
      setState(() {
        // Trigger a UI update (this might be inside a StatefulWidget)
      });
      return true;
    } catch (e) {
      print("Error fetching interaction: $e");
    }
    return false;
  }

  Future<bool> fetchKaryakartha(List<dynamic> KR_ids) async {
      try {
        for (var KR in KR_ids) {  // Corrected loop syntax
          var result = await apiService.getKaryakartha(KR);  // Call your service
          karyakartha.add(result);
        }
        setState(() {

        });
        return true;
      } catch (e) {
        print("Error fetching interaction: $e");
      }
      return false;
    }

  Future<bool> fetchEvent(Event_id)async{
    try{
      var result = await apiService.getInteractionByID(Event_id);
      setState(() {
        Interaction = result;
        titleDataController.text = Interaction[0]['title']??'';
        placeDataController.text = Interaction[0]['meeting_place']??'';
        selectedMeetDate = DateTime.parse(Interaction[0]['meeting_datetime']??'');
        selectedStatus = Interaction[0]['status'];
        descriptionController.text = Interaction[0]['description'];
        materials_distributedController.text = Interaction[0]['materials_distributed']??'';
        virtual_meeting_linkController.text = 'virtualLink'??'';
        discussion_pointsController.text = Interaction[0]['discussion_points'];
      });
      setState(() {

      });
      return true;
    } catch (e) {
      print("Error fetching interaction: $e");
    }
    return false;
  }

  Future<bool> fetchEventImages(Event_id)async{
      try{
        var imageResult = await apiService.getEventImages(widget.id, widget.type);
        setState(() {
          images = imageResult;
          print('images = ${images[0]['images'].length}');
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
                            'Title: ${widget.data['title']}',
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
                                  'Description:\n          ${widget.data['description']}',
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
                                  'Place: ${widget.data['venue']}',
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
                                  'Date & Time: ${widget.data['meeting_datetime'] == null ? "Date & Time not set" : "${DateTime.parse(widget.data['meeting_datetime']??'').toLocal()}".split(' ')[0]}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: widget.data['meeting_datetime'] == null ? Colors.red : Colors.green,
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
                        if(images.isNotEmpty)
                          Wrap(
                          spacing: 8.0,  // Horizontal spacing between items
                          runSpacing: 8.0,  // Vertical spacing between rows
                          children: [
                            // Generate image boxes dynamically
                            ...List.generate(images[0]['images'].length, (index) {
                              String base64Image = images[0]['images'][index];
                              return Container(
                                width: (MediaQuery.of(context).size.width * 0.80) / 3,  // 90% of screen width divided by 3 images
                                height: (MediaQuery.of(context).size.width * 0.80) / 3 + 15,  // Fixed height for each image
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: base64Image.isNotEmpty
                                      ? Image.memory(
                                    base64Decode(base64Image),
                                    fit: BoxFit.cover,
                                  )
                                      : Container(color: Colors.grey[200]),  // Default background color if no image
                                ),
                              );
                            }),
                          ],
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


                        if(GanyaVyakthis.isNotEmpty)
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
                                    if (GanyaVyakthis.isNotEmpty)
                                      Column(
                                        children: List.generate(
                                          (GanyaVyakthis.length < 4) ? GanyaVyakthis.length : 3, // Display either all members or just 3
                                              (index) {
                                            final influencer = GanyaVyakthis[index]; // Access the member data
                                            return Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 10, top: 10,bottom: 10),
                                              child: InfluencerCard(
                                                id: influencer[0]['id']!,
                                                name: influencer[0]['fname']??'',
                                                designation: influencer[0]['designation']!,
                                                description: influencer[0]['description']??'',
                                                hashtags: influencer[0]['hashtags']??'',
                                                soochi: influencer[0]['soochi']??'',
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

                        /*if(images.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
                              itemCount: images[0]['images'].length,
                              itemBuilder: (context, index) {
                                String base64Image = images[0]['images'][index];
                                return CircleAvatar(
                                  radius: MediaQuery.of(context).size.width * 0.08,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: base64Image.isNotEmpty
                                      ? MemoryImage(base64Decode(base64Image.split(',')[1]))
                                      : null,
                                  child: base64Image.isEmpty
                                      ? Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: MediaQuery.of(context).size.width * 0.14,
                                  )
                                      : null,
                                );
                              },
                            ),
                          ),
*/


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
                                                first_name: member[0]['first_name']!,
                                                last_name: member[0]['last_name']!,
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

class MemberCard extends StatelessWidget {
  final String id;
  final String first_name;
  final String last_name;
  final String designation;
  final String profileImage;

  const MemberCard({
    super.key,

    required this.first_name,
    required this.last_name,
    required this.designation,
    required this.profileImage,
    required this.id,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfilePage(id)),
          );
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
              // Profile Picture (placeholder)
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.08,
                backgroundColor: Colors.grey[200],
                backgroundImage: profileImage.isNotEmpty ? MemoryImage(base64Decode(profileImage.split(',')[1])) : null, // Use NetworkImage here
                child: profileImage.isEmpty
                    ? Icon(
                  Icons.person,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.14,
                )
                    : null,
              ),
              SizedBox(width: 16),
              // Influencer Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$first_name $last_name', // Dynamic name
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                    Text(
                      designation, // Dynamic designation
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                    SizedBox(height: 1),
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

class InfluencerCard extends StatelessWidget {
  final String id;
  final String name;
  final String designation;
  final String description;
  final String hashtags;
  final String soochi;
  final String itrLvl;
  final String profileImage;

  const InfluencerCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags,
    required this.profileImage,
    required this.id,
    required this.soochi,
    required this.itrLvl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfluencerProfilePage(id)),
                );
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
                    // Profile Picture (placeholder)
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.08,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profileImage.isNotEmpty ? MemoryImage(base64Decode(profileImage.split(',')[1])) : null,
                      //backgroundImage: profileImage.isNotEmpty ? MemoryImage(base64Decode(profileImage.split(',')[1])) : null, // Use NetworkImage here
                      child: profileImage.isEmpty
                          ? Icon(
                        Icons.person,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width * 0.14,
                      )
                          : null,
                    ),
                    SizedBox(width: 16),
                    // Influencer Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name, // Dynamic name
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(5, 50, 70, 1.0),
                            ),
                          ),
                          Text(
                            designation, // Dynamic designation
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(5, 50, 70, 1.0),
                            ),
                          ),
                          Text(
                            description, // Dynamic designation
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(5, 50, 70, 1.0),
                            ),
                          ),
                          Text(
                            hashtags, // Dynamic designation
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(height: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 15,
          child: Container(
            width: 25,  // Diameter of the circle
            height: 25,
            decoration: BoxDecoration(
              color: Color.fromRGBO(59, 171, 144, 1.0),  // Blue background color
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color.fromRGBO(198, 198, 198, 1.0), // Border color
                width: 0.8, // Border width
              ),
            ),
            child: Center(
              child: Text(
                soochi,  // The letter inside the circle
                style: TextStyle(
                  fontSize: 13,  // Font size for "L"
                  color: Colors.white,  // White color for the letter
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 35,
          child: Container(
            width: 25,  // Diameter of the circle
            height: 25,
            decoration: BoxDecoration(
              color: Colors.blue,  // Blue background color
              shape: BoxShape.circle,  // Make it a circle
              border: Border.all(
                color: const Color.fromRGBO(198, 198, 198, 1.0), // Border color
                width: 0.8, // Border width
              ),
            ),
            child: Center(
              child: Text(
                itrLvl,  // The letter inside the circle
                style: TextStyle(
                  fontSize: 13,  // Font size for "L"
                  color: Colors.white,  // White color for the letter
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}
