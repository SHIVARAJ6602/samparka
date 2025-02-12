import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:samparka/Screens/schedule_interaction.dart';
import 'package:samparka/Screens/view_influencers.dart';
import 'package:samparka/Screens/view_interaction.dart';

import '../Service/api_service.dart';

class InfluencerProfilePage extends StatefulWidget {

  final String id;

  // Receiving the id directly through the constructor
  InfluencerProfilePage(this.id);

  @override
  _InfluencerProfilePageState createState() => _InfluencerProfilePageState();
}

class _InfluencerProfilePageState extends State<InfluencerProfilePage> {

  final apiService = ApiService();

  List<dynamic> meetings = [{"id":"MT00001","title":"meet1","description":"adadad"},{"id":"MT00002","title":"meet2","description":"adadad"}];
  late List<dynamic> result;
  List<dynamic> tasks = [];
  List<dynamic> interactions = [];

  late String name = '';
  late String designation = '';
  late String description = '';
  late String hashtags = 'hastags';
  late String profileImage = '';
  late String GV_id = '';

  TextEditingController titleController = TextEditingController();

  late bool loading = true;

  @override
  void initState() {
    super.initState();
    setState(() {loading = true;});
    GV_id = widget.id;
    print(GV_id[0][0]);
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

  Future<bool> getGanyavyakthi() async{
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getGanyavyakthi(GV_id);
      setState(() {
        // Update the influencers list with the fetched data
        //meetings = result;
        print(result[0]['fname']);
        name = result[0]['fname'];
        designation = result[0]['designation'];
        description = result[0]['description'];
        name = result[0]['fname'];
        name = result[0]['fname'];
        profileImage = result[0]['profile_image'];
        print('Image: ${result[0]['profile_image']}');
        setState(() {});

      });
      return true;
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
    return false;
  }

  Future<void> fetchTasks(GV_id) async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getTasks(GV_id);
      setState(() {
        // Update the influencers list with the fetched data
        tasks = result;
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching interactions: $e");
    }
  }

  Future<void> fetchInteraction(GV_id) async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getInteraction(GV_id);
      setState(() {
        // Update the influencers list with the fetched data
        meetings = result;
        print('interactions: $meetings');
      });
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
  }

  Future<bool> fetchInfluencers() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.homePage();
      setState(() {
        // Update the influencers list with the fetched data
        //meetings = result;
      });
      return true;
    } catch (e) {
      // Handle any errors here
      print("Error fetching influencers: $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    String GV_id = widget.id;
    print(GV_id);
    print(widget.id);
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar background transparent
        elevation: 0, // Remove the app bar shadow
        actions: [
          // Add the notification icon to the right side of the app bar
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromRGBO(5, 50, 70, 1.0)), // Notification icon
            onPressed: () {
              // Handle the notification icon tap here (you can add navigation or other actions)
              print('Notifications tapped');
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
                              ],
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
                                  Row(
                                    children: [
                                      Text(
                                        designation, // Dynamic designation
                                        style: TextStyle(
                                          fontSize: smallFontSize,
                                          color: Color.fromRGBO(5, 50, 70, 1.0),
                                        ),
                                      ),
                                      Container(
                                        width: 2, // Divider width
                                        height: smallFontSize, // Divider height (you can adjust this as needed)
                                        color: Colors.black, // Divider color
                                        margin: EdgeInsets.symmetric(horizontal: 8), // Add spacing around the divider
                                      ),
                                      Text(
                                        'Shreni', // Dynamic designation
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
                                  //sahavasa
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    height: largeFontSize+5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Color.fromRGBO(14, 57, 196,1.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Sahavasa',
                                        style: TextStyle(
                                          fontSize: smallFontSize-3,
                                          color: Colors.white,
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //change request
                            Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width*0.25,
                                  height: MediaQuery.of(context).size.width*0.25*0.5,
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
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Change\nRequest ',
                                            style: TextStyle(
                                              fontSize: smallFontSize-3,
                                              color: Colors.white,
                                              //fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 1),  // Add space between the text and the image
                                          Transform.rotate(
                                            angle: 5.7,  // Adjust the rotation angle here as needed
                                            child: Icon(
                                              Icons.arrow_forward,  // You might want to use arrow_forward or another arrow icon
                                              color: Colors.white,
                                              size: largeFontSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(description,style: TextStyle(fontSize: normFontSize)),
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
                                    itemCount: tasks.length,  // The length of your tasks array
                                    itemBuilder: (context, index) {
                                      var task = tasks[index];  // Get the task at the current index
                                      return Card(
                                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                        child: ListTile(
                                          title: Text(task['title']),  // Display the task title
                                          trailing: IconButton(
                                            icon: Icon(Icons.check_circle_outline,color: task['completed'] ? Colors.green : Colors.red,),

                                              onPressed: () async {
                                              // Call API to mark task as complete
                                              bool isTaskCompleted = await apiService.markTaskComplete(task['id']);
                                              if (isTaskCompleted) {
                                                // Update the task status locally or refresh the task list
                                                setState(() {
                                                  task['completed'] = true;  // You can also update your task list state if needed
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
                                      children: tasks.map<Widget>((task) {
                                        return Card(
                                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          child: ListTile(
                                            title: Text(task['title']),  // Display the task title
                                            trailing: IconButton(
                                              icon: Icon(Icons.check_circle_outline, color: task['completed'] ? Colors.green : Colors.red,),
                                              onPressed: () async {
                                                // Call API to mark task as complete
                                                bool isTaskCompleted = await apiService.markTaskComplete(task['id']);
                                                if (isTaskCompleted) {
                                                  // Update the task status locally or refresh the task list
                                                  setState(() {
                                                    task['completed'] = true;  // You can also update your task list state if needed
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
                                    backgroundColor: Colors.blue,
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
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: meetings.length, // The number of items in your data list
                                    itemBuilder: (context, index) {
                                      final meeting = meetings[index]; // Access the influencer data for each item
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8, top: 12),
                                        child: meetingCard(
                                          title: meeting['title']!,
                                          description: meeting['description']!,
                                          id: meeting['id']!,
                                        ),
                                      );
                                    },
                                  ),

                              if (meetings.isNotEmpty)
                              // View All Influencers Button
                                TextButton(
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => InfluencerProfilePage('GV00000001')),
                                    );
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
                                ),

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
  final String id;

  const meetingCard({
    super.key,
    required this.title,
    required this.description,
    required this.id,
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: largeFontSize),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        description,
                        style: TextStyle(fontSize: smallFontSize),
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