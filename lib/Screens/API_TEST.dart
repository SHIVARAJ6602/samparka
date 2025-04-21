import 'package:flutter/material.dart';
import 'package:samparka/Screens/influencer_profile.dart';
import 'package:samparka/Screens/settings.dart';
import 'package:samparka/Screens/submit_report.dart';
import 'package:samparka/Screens/update_user_profile.dart';
import 'package:samparka/Screens/upload_gv_excel.dart';
import 'package:samparka/Screens/upload_kr_excel.dart';
import 'package:samparka/Service/api_service.dart';
import 'Temp2.dart';
import 'add_inf.dart';
import 'drop_down.dart';
import 'register_user.dart';
import 'temp.dart';

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});


  @override
  _ApiScreenState createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  final apiService = ApiService();
  late Future<List<dynamic>> tasks;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _url = TextEditingController();
  final TextEditingController _mail = TextEditingController();
  late String mail = 'example@gmail.com';

  @override
  void initState() {
    super.initState();
    //apiService.loadData();
    tasks = apiService.fetchTasks();
  }

  Future<bool> _addTask(String title) async {
    try {
      await apiService.addTask(title);
      setState(() {
        tasks = apiService.fetchTasks(); // Refresh the task list
      });
      _taskController.clear(); // Clear the input field
    } catch (e) {
      print('Error adding task: $e');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      appBar: AppBar(title: const Text('API')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: 'Enter a new task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    apiService.getHashtags();
                  },
                  child: const Text('get Hashtags'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: tasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final tasks = snapshot.data!;
                  if (tasks.isEmpty) {
                    return const Center(child: Text('No tasks available.'));
                  } else {
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(tasks[index]['title']),
                          trailing: Checkbox(
                            value: tasks[index]['completed'],
                            onChanged: (bool? value) {},
                          ),
                        );
                      },
                    );
                  }
                } else {
                  return const Center(child: Text('No data available.'));
                }
              },
            ),
          ),
          Expanded(
            child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      apiService.userAuth();
                    },
                    child: Text('userAuthTest'))
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      apiService.getUser();
                    },
                    child: Text('get User')
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UploadKRExcel()),
                          );
                        },
                          child: Text('add KR upload')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UploadGVExcel()),
                            );
                          },
                          child: Text('add GV upload')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateUserPage(apiService.UserId)),
                            );
                          },
                          child: Text('Update User')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.getInfluencer(0,3,"KR00000001");
                          },
                          child: Text('My Influencer')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TempPage()),
                            );
                          },
                          child: Text('Temp page')
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.Subordinates();
                          },
                          child: Text('view Subordinates')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.RecurSubordinates();
                          },
                          child: Text('view RecurSubordinates')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.getGanyavyakthi('getGanyavyakthi');
                          },
                          child: Text('get gv')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.mySupervisor();
                          },
                          child: Text('My Supervisor')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TempPage()),
                            );
                          },
                          child: Text('Temp page')
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      apiService.getInteractionByID("IR00000001");
                    },
                    child: Text('Get Interaction')
                ),
                TextButton(
                    onPressed: () {
                      apiService.getEvents('1');
                    },
                    child: Text('Get Baitak')
                ),
                TextButton(
                    onPressed: () {
                      apiService.getEvents('2');
                    },
                    child: Text('Get prgm')
                ),
                TextButton(
                    onPressed: () {
                      apiService.getEvents('3');
                    },
                    child: Text('Get SGM')
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      //apiService.baseUrl = "https://llama-curious-adequately.ngrok-free.app/api";
                      apiService.saveData();
                      apiService.loadData();
                    },
                    child: Text('load and save data')
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mail,
                    decoration: InputDecoration(
                      labelText: mail,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    print(_mail.text.trim());
                    await apiService.sendEmail(_mail.text);
                    setState(() {});
                  },
                  child: const Text('sendMail'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.getOTP("7337620623","shivaraj6602@gmail.com");
                          },
                          child: Text('getOtp')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.getEventByStatus();
                          },
                          child: Text('EventByStatus')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            //apiService.submit
                          },
                          child: Text('Add inf 1')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.getUser();
                          },
                          child: Text('User Data')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.getEvents('1');
                          },
                          child: Text('get baitek')
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      //apiService.addGV();
                    },
                    child: Text('add GV')
                ),
                TextButton(
                    onPressed: () {
                      //apiService.addUsers();
                    },
                    child: Text('add user')
                ),
                TextButton(
                    onPressed: () {
                      apiService.genReport('2025-02-08T00:00:00.000','2025-02-27T00:00:00.000');
                    },
                    child: Text('gen Report')
                ),
                TextButton(
                    onPressed: () {
                      apiService.searchGV('sa');
                    },
                    child: Text('search GV')
                ),
                TextButton(
                    onPressed: () {
                      //apiService.getReportPage();
                    },
                    child: Text('ReportPage')
                ),
              ],
            ),
          ),

          /*Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _url,
                    decoration: InputDecoration(
                      labelText: apiService.baseUrl,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    print(_url.text.trim());
                    apiService.saveUrl(_url.text.trim());
                    setState(() {});
                  },
                  child: const Text('Change URL'),
                ),
              ],
            ),
          ),*/
        ],
      ),
    );
  }
}
