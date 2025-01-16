import 'package:flutter/material.dart';
import 'package:samparka/Service/api_service.dart';
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final title = _taskController.text.trim();
                    if (title.isNotEmpty) {
                      await _addTask(title);
                    }
                  },
                  child: const Text('Add Task'),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterUserPage()),
                      );
                    },
                    child: Text('RegisterUSer')
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
                          apiService.CreateGanyaVyakthi();
                          },
                          child: Text('Add GV')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.homePage();
                          },
                          child: Text('Home Page')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.myTeam(0,100);
                          },
                          child: Text('My Team')
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            apiService.myInfluencer(0,3);
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
                      apiService.getGroups();
                    },
                    child: Text('Get Groups')
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                TextButton(
                    onPressed: () {
                      apiService.baseUrl = "https://llama-curious-adequately.ngrok-free.app/api";
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
                Text(apiService.txt)
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
