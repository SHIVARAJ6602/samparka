import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:samparka/Screens/update_influencer_profile.dart';
import 'package:samparka/Screens/schedule_interaction.dart';
import 'package:samparka/Screens/view_interaction.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:fluttertoast/fluttertoast.dart'; // For Toast
import 'package:url_launcher/url_launcher.dart';

import '../Service/api_service.dart';

class InfluencerProfilePage extends StatefulWidget {

  final String id;

  // Receiving the id directly through the constructor
  const InfluencerProfilePage(this.id, {super.key});

  @override
  InfluencerProfilePageState createState() => InfluencerProfilePageState();
}

class InfluencerProfilePageState extends State<InfluencerProfilePage> {

  final apiService = ApiService();

  List<dynamic> meetings = [{"id":"MT00001","title":"meet1","description":""},{"id":"MT00002","title":"meet2","description":""}];
  late List<dynamic> result;
  List<dynamic> tasks = [];
  List<dynamic> interactions = [];

  late String name = '';
  late String designation = '';
  late String description = '';
  late String interactionLevel = '';
  late String soochi = '';
  late String shreni = '';
  late String hashtags = '';
  List<dynamic> fetchedHashtags = [];
  bool isTagsLoaded = false;
  late String profileImage = '';
  late String GV_id = '';
  late String IOS = '';
  late String Phno = '';
  late String address = '';
  late String email = '';
  late String state = '';
  late String district = '';
  late String organisation = '';
  late String assignedKaryakartha = '';

  TextEditingController titleController = TextEditingController();

  late bool loading = true;

  @override
  void initState() {
    super.initState();
    setState(() {loading = true;});
    GV_id = widget.id;
    //log(GV_id[0][0]);
    fetchHashtags();
    getGanyavyakthi();
    fetchTasks(GV_id);
    fetchInteraction(GV_id);
    setState(() {});
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        loading = false; // Set loading to false after 2 seconds
      });
    });
  }

  Future<void> fetchHashtags() async {
    try {
      // Call the apiService.homePage() and store the result
      var tags = await apiService.getHashtags();
      setState(() {
        fetchedHashtags = tags;
        //log('hashtags\'s $result');
        isTagsLoaded = true;
      });

    } catch (e) {
      log("Error fetching tags: $e");
    }
  }

  String getHashtagNames(dynamic influencerHashtagIds, dynamic allHashtags) {
    final List<int> ids = List<int>.from(influencerHashtagIds ?? []);
    final List<Map<String, dynamic>> hashtags =
    List<Map<String, dynamic>>.from(allHashtags ?? []);

    final matchedNames = ids.map((id) {
      final tag = hashtags.firstWhere(
            (tag) => tag['id'] == id,
        orElse: () => {},
      );
      final name = tag['name'];
      return name != null ? '#$name' : '';
    }).where((name) => name.isNotEmpty).join(', ');

    return matchedNames;
  }


  String soochi1 = "AkhilaBharthiya";
  String abbreviation1 = "AB";

  String soochi2 = "PranthyaSampark";
  String abbreviation2 = "PS";

  String soochi3 = "JillaSampark";
  String abbreviation3 = "JS";

  bool showAbbreviation = true;

  Future<bool> getGanyavyakthi() async{
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getGanyavyakthi(GV_id);
      setState(() {
        // Update the influencers list with the fetched data
        //meetings = result;
        name = '${result[0]['fname'] ?? ''} ${result[0]['lname'] ?? '.'}';
        designation = result[0]['designation']??'';
        description = result[0]['description']??'';
        IOS = result[0]['impact_on_society']??'';
        if (result[0]['soochi'] == 'AkhilaBharthiya'){
          soochi = 'AB';
        }else if(result[0]['soochi'] == 'PranthyaSampark'){
          soochi = 'PS';
        }else if(result[0]['soochi'] == 'JillaSampark'){
          soochi = 'JS';
        }
        shreni = result[0]['shreni']??'';
        Phno = result[0]['phone_number']??'';
        address = result[0]['address']??'';
        state = result[0]['state']??'';
        district = result[0]['district']??'';
        email = result[0]['email']??'';
        organisation = result[0]['Organization']??'';
        interactionLevel = result[0]['interaction_level']??'';
        profileImage = result[0]['profile_image']??'';
        assignedKaryakartha = result[0]['assigned_karyakarta']??'';
        hashtags = getHashtagNames(result[0]['hashtags'], fetchedHashtags);
        //log('Image: ${result[0]['profile_image']??''}');
        //log('$result');
        setState(() {});

      });
      await waitForTagsToLoad(); // Wait until tags are loaded

      final resolvedHashtags = getHashtagNames(result[0]['hashtags'], fetchedHashtags);
      setState(() {
        hashtags = resolvedHashtags;
      });


      return true;
    } catch (e) {
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
    return false;
  }

  Future<void> waitForTagsToLoad() async {
    while (!isTagsLoaded) {
      await Future.delayed(Duration(milliseconds: 1000));
    }
  }

  Future<void> fetchTasks(GV_id) async {
    try {
      // Call the apiService.homePage() and store the result
      var result = await apiService.getTasks(GV_id);
      setState(() {
        // Update the influencers list with the fetched data
        tasks = result;
      });
    } catch (e) {
      // Handle any errors here
      log("Error fetching interactions: $e");
    }
  }

  Future<void> fetchInteraction(GV_id) async {
    try {
      // Call the apiService.homePage() and store the result
      var result = await apiService.getInteraction(GV_id);
      setState(() {
        // Update the influencers list with the fetched data
        meetings = result;
        //log('interactions: $meetings');
      });
    } catch (e) {
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
  }


  void _showPopup(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2;
    largeFontSize = largeFontSize;
    smallFontSize = smallFontSize;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          title: Text("Influencer Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: $name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                Divider(),
                Text("Email: $email", style: TextStyle(fontSize: 16)),
                Divider(),
                Text("Address: $address", style: TextStyle(fontSize: 16)),
                Text("District: $district", style: TextStyle(fontSize: 16)),
                Text("State: $state", style: TextStyle(fontSize: 16)),
                Divider(),
                Text("Phone: $Phno", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final call = Uri.parse('tel:+91 $Phno');
                        if (await canLaunchUrl(call)) {
                          launchUrl(call);
                        } else {
                          throw 'Could not launch $call';
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.call),
                          SizedBox(width: 5),
                          Text("Call"),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final web = Uri.parse('https://wa.me/$Phno');
                        if (await canLaunchUrl(web)) {
                          launchUrl(web);
                        } else {
                          throw 'Could not launch $web';
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.chat),
                          SizedBox(width: 5),
                          Text("WhatsApp"),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            if(assignedKaryakartha.isNotEmpty && assignedKaryakartha==apiService.UserId)
            Container(
              width: MediaQuery.of(context).size.width * 0.25 * 1.1,
              height: MediaQuery.of(context).size.width * 0.25 * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromRGBO(133, 1, 1, 1.0),
                    Color.fromRGBO(237, 62, 62, 1.0),
                  ],
                ),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // First pop the current screen/dialog
                  Future.delayed(Duration(milliseconds: 30), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangeRequestPage(GV_id)),
                    ).then((result) {
                      if (result == true) {
                        getGanyavyakthi(); // Refresh after returning
                      }
                    });
                  });
                } ,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Transform.rotate(
                        angle: 5.7,
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: SizedBox(height: 1)),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _copyPhoneNumber(String phoneNumber) {
    Clipboard.setData(ClipboardData(text: phoneNumber)); // Copy to clipboard
    Fluttertoast.showToast(
      msg: "$phoneNumber copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    String GV_id = widget.id;
    //log(GV_id);
    //log(widget.id);
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        actions: [
          // Add the notification icon to the right side of the app bar
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromRGBO(5, 50, 70, 1.0)), // Notification icon
            onPressed: () {
              // Handle the notification icon tap here (you can add navigation or other actions)
              //log('Notifications tapped');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //inf details
                        Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: (MediaQuery.of(context).size.width * 0.80) / 3.0,  // 90% of screen width divided by 3 images
                                  height: (MediaQuery.of(context).size.width * 0.80) / 3.0,  // Fixed height for each image
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: Colors.grey.shade400),
                                    color: Colors.grey[200],
                                    boxShadow: [
                                      if(profileImage.isNotEmpty)
                                        BoxShadow(
                                          color: Color.fromRGBO(5, 50, 70, 1.0).withOpacity(0.5), // Grey shadow color with opacity
                                          spreadRadius: 1, // Spread radius of the shadow
                                          blurRadius: 7, // Blur radius of the shadow
                                          offset: Offset(0, 4), // Shadow position (x, y)
                                        ),
                                      if(profileImage.isEmpty)
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5), // Grey shadow color with opacity
                                          spreadRadius: 1, // Spread radius of the shadow
                                          blurRadius: 3, // Blur radius of the shadow
                                          offset: Offset(0, 4), // Shadow position (x, y)
                                        ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: (profileImage.isNotEmpty)
                                        ? Image.network(
                                      profileImage,  // Ensure the URL is encoded
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;  // Image loaded successfully
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  (loadingProgress.expectedTotalBytes ?? 1)
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.white,  // Placeholder color for invalid image URLs
                                          child: Center(
                                            child: Icon(Icons.error, color: Colors.grey),  // Display error icon
                                          ),
                                        );
                                      },
                                    )
                                        : Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: MediaQuery.of(context).size.width * 0.14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                            // Influencer Details
                            TextButton(
                              onPressed: () {
                                _showPopup(context);
                              },
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.38),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double fontSize = largeFontSize + 6; // Default font size
                                        double availableWidth = name.length*largeFontSize;
                                        //log('$fontSize $availableWidth ${MediaQuery.of(context).size.width * 0.38*2}');

                                        if (availableWidth > MediaQuery.of(context).size.width * 0.38*2) {
                                          fontSize = 16; // Adjust this to your needs
                                        }

                                        return Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: fontSize, // Adjusted font size
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(5, 50, 70, 1.0),
                                          ),
                                          overflow: TextOverflow.ellipsis, // Truncate with ellipsis if the text overflows
                                          softWrap: false, // Prevent wrapping
                                        );
                                      },
                                    ),

                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          designation, // Dynamic designation
                                          style: TextStyle(
                                            fontSize: smallFontSize,
                                            color: Color.fromRGBO(5, 50, 70, 1.0),
                                          ),
                                        ),
                                        Text(
                                          shreni, // Dynamic designation
                                          style: TextStyle(
                                            fontSize: smallFontSize,
                                            color: Color.fromRGBO(5, 50, 70, 1.0),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      hashtags, // Dynamic designation
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    // Sahavas (Row with Containers)
                                    Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.20,
                                          height: largeFontSize + 5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            color: Color.fromRGBO(14, 57, 196, 1.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              interactionLevel,
                                              style: TextStyle(
                                                fontSize: smallFontSize,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 3),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.15,
                                          height: largeFontSize + 5,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            color: Color.fromRGBO(59, 171, 144, 1.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              soochi,
                                              style: TextStyle(
                                                fontSize: smallFontSize,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //change request
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.info_outline),
                                  onPressed: () => _showPopup(context),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                        SizedBox(height: 26),
                        Divider(),
                        Text('Short Description:',style: TextStyle(fontSize: largeFontSize,color: Color.fromRGBO(2, 40, 60, 1),fontWeight: FontWeight.bold)),
                        //SizedBox(height: 5),
                        Text('   $description',style: TextStyle(fontSize: normFontSize)),
                        SizedBox(height: 10,),
                        Text('Impact On Society:',style: TextStyle(fontSize: largeFontSize,color: Color.fromRGBO(2, 40, 60, 1),fontWeight: FontWeight.bold)),
                        SizedBox(height: 1),
                        Text('   $IOS',style: TextStyle(fontSize: normFontSize)),
                        Divider(),
                        SizedBox(height: 16),
                        //Tasks
                        Row(
                          children: [
                            Text(
                              'Tasks',
                              style: TextStyle(
                                color: Color.fromRGBO(2, 40, 60, 1),
                                fontSize: 24, // Replace with your largeFontSize + 8 if needed
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(child: SizedBox()),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Color.fromRGBO(2, 40, 60, 1),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  // Show dialog to input title for the task
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      TextEditingController titleController = TextEditingController(); // Controller for text input

                                      return AlertDialog(
                                        title: Text("Enter Task Title"),
                                        content: TextField(
                                          controller: titleController,
                                          decoration: InputDecoration(hintText: "Task title"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              String title = titleController.text.trim();
                                              if (title.isNotEmpty) {
                                                // Call ApiService to create the task
                                                bool isTaskCreated = await apiService.createTask(GV_id, title);
                                                Navigator.pop(context);
                                                if (isTaskCreated) {
                                                  fetchTasks(GV_id);
                                                  // Show a dialog to confirm task creation
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false, // Prevents dismissing by tapping outside the dialog
                                                    builder: (BuildContext context) {
                                                      // Displaying the dialog
                                                      Future.delayed(Duration(seconds: 2), () {
                                                        Navigator.pop(context); // Close the dialog after 2 seconds
                                                      });

                                                      return AlertDialog(
                                                        title: Text('Task Created'),
                                                        content: Text('The task was created successfully!'),
                                                      );
                                                    },
                                                  );
                                                  setState(() {});
                                                }
                                                else{
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false, // Prevents dismissing by tapping outside the dialog
                                                    builder: (BuildContext context) {
                                                      // Displaying the dialog
                                                      Future.delayed(Duration(seconds: 2), () {
                                                        Navigator.pop(context); // Close the dialog after 2 seconds
                                                      });

                                                      return AlertDialog(
                                                        title: Text('Something went wrong'),
                                                        content: Text('Failed to create task'),
                                                      );
                                                    },
                                                  );
                                                }
                                              } else {
                                                // Show a message if the title is empty
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Please enter a task title"),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text("Create Task"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context); // Close the dialog
                                            },
                                            child: Text("Cancel"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+ Add Task',
                                        style: TextStyle(
                                          fontSize: 14, // Replace with your smallFontSize if needed
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        if(tasks.isNotEmpty)
                          if(tasks.length>3)
                            Container(
                            height: 240,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      var task = tasks[index];
                                      return Card(
                                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                        child: ListTile(
                                          title: Text(task['title']),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.check_circle_outline,
                                                  color: task['completed'] ? Colors.green : Colors.red,
                                                ),
                                                onPressed: () async {
                                                  bool isTaskCompleted = await apiService.markTaskComplete(task['id']);
                                                  if (isTaskCompleted) {
                                                    setState(() {
                                                      task['completed'] = true;
                                                    });
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Task marked as completed!")),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Failed to mark task as completed")),
                                                    );
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete_outline, color: Colors.red),
                                                onPressed: () async {
                                                  bool isTaskDeleted = await apiService.deleteTask(task['id']);
                                                  if (isTaskDeleted) {
                                                    setState(() {
                                                      tasks.removeAt(index);
                                                    });
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Task deleted!")),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Failed to delete the task")),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if(tasks.length<=3)
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: tasks.asMap().entries.map<Widget>((entry) {
                                        int index = entry.key;
                                        var task = entry.value;

                                        return Card(
                                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          child: ListTile(
                                            title: Text(task['title']),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.check_circle_outline,
                                                    color: task['completed'] ? Colors.green : Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    bool isTaskCompleted = await apiService.markTaskComplete(task['id']);
                                                    if (isTaskCompleted) {
                                                      setState(() {
                                                        task['completed'] = true;
                                                      });
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Task marked as completed!")),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Failed to mark task as completed")),
                                                      );
                                                    }
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete_outline, color: Colors.red),
                                                  onPressed: () async {
                                                    bool isTaskDeleted = await apiService.deleteTask(task['id']);
                                                    if (isTaskDeleted) {
                                                      setState(() {
                                                        tasks.removeAt(index);
                                                      });
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Task deleted!")),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("Failed to delete the task")),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        if(tasks.isEmpty)
                          Center(
                            child: Text("No tasks created",style: TextStyle(fontSize: largeFontSize,fontWeight: FontWeight.bold),),
                          ),
                        SizedBox(height: 16),
                        //new meeting button
                        Row(
                          children: [
                            Text('Recent Meeting',style: TextStyle(color: Color.fromRGBO(2, 40, 60, 1),fontSize: largeFontSize+8,fontWeight: FontWeight.bold),),
                            Expanded(child: SizedBox()),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 0,horizontal: 4),
                              //width: MediaQuery.of(context).size.width*0.25,
                              //height: largeFontSize+6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Color.fromRGBO(2, 40, 60, 1),
                              ),
                              child: TextButton(
                                onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AddInteractionPage(GV_id)),
                                    );
                                  },
                                style: TextButton.styleFrom(
                                  //padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+ Add Meeting',
                                        style: TextStyle(
                                          fontSize: smallFontSize,
                                          color: Colors.white,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // meetings Cards
                        Container(
                          child: Column(
                            children: [
                              // If the list is empty, show a message
                              if (loading)
                                Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  ),
                                )
                              else
                                if (meetings.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(16), // Optional, for spacing inside the container
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No Meetings Available',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(2, 40, 60, 1),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: List.generate(meetings.length, (index) {
                                      final meeting = meetings[index]; // Access the meeting data for each item
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
                                        child: meetingCard(
                                          title: meeting['title']!,
                                          description: meeting['description']!,
                                          dateTime: meeting['meeting_datetime']??'0000-00-00T00:00:00+00:00',
                                          id: meeting['id']!,
                                        ),
                                      );
                                    }),
                                  ),

                              /*ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: meetings.length, // The number of items in your data list
                                    itemBuilder: (context, index) {
                                      final meeting = meetings[index]; // Access the influencer data for each item
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
                                        child: meetingCard(
                                          title: meeting['title']!,
                                          description: meeting['description']!,
                                          dateTime: meeting['meeting_datetime']!,
                                          id: meeting['id']!,
                                        ),
                                      );
                                    },
                                  ),*/

                              //if (meetings.isNotEmpty)
                              // View All Influencers Button
                                /*TextButton(
                                  onPressed: () async {
                                    /*Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => InfluencerProfilePage('GV00000001')),
                                    );*/
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'View all Meetings',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Image.asset(
                                        'assets/icon/arrow.png',
                                        color: Colors.grey[800],
                                        width: 12,
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                ),*/

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            ],
          ),
          if (loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10), // Space between the indicator and text
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class meetingCard extends StatelessWidget {
  final String title;
  final String description;
  final String dateTime;
  final String id;

  const meetingCard({
    super.key,
    required this.title,
    required this.description,
    required this.id,
    required this.dateTime,
  });


  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2;
    return Container(
      //padding: const EdgeInsets.all(0), // Container padding
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // Bottom border color
            width: 1, // Bottom border width
          ),
        ),
      ),

      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ViewInteractionPage(id)),
          );
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          )),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 0,right: 0,bottom: 4,top: 0), // Add padding to the content
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align all children to the start
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.6, // 50% width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0), // Space between text
                      child: Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: largeFontSize,color: Color.fromRGBO(5, 50, 70, 1.0)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        description,
                        style: TextStyle(fontSize: smallFontSize,color: Color.fromRGBO(5, 50, 70, 1.0)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        DateFormat('yyyy-MM-dd HH:mm a').format(DateTime.parse(dateTime)),
                        style: TextStyle(fontSize: smallFontSize,color: Color.fromRGBO(0, 0, 0, 1)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: SizedBox()), // Fills the remaining space
              //arrow
              Center(
                child: Column(
                  children: [
                    Transform.rotate(
                      angle: 4.7124,  // Rotate the arrow 90 degrees
                      child: Image.asset(
                        'assets/icon/arrow.png',
                        color: Colors.grey,
                        width: 15,  // Adjust the size of the image
                        height: 15, // Adjust the size of the image
                      ),
                    ),
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
//delete Button
/*
TextButton.icon(
  onPressed: () async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Profile'),
        content: Text('Are you sure you want to delete this GanyaVyakthi profile? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );

    if (confirm) {
      bool success = await apiService.deleteGanyaVyakthi(GV_id);
      if (success) {
        Navigator.pop(context); // Or go to list page
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile deleted successfully.")));
      }
    }
  },
  icon: Icon(Icons.delete, color: Colors.red),
  label: Text("Delete Profile", style: TextStyle(color: Colors.red)),
)
*/