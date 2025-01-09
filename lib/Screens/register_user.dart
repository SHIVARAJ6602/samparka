import 'package:flutter/material.dart';
import 'package:samparka/Service/api_service.dart';

class RegisterUserPage extends StatefulWidget {

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUserPage> {

  final apiService = ApiService();

  // Controllers to handle the input data
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variables to store the data
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String designation = '';
  String password = '';
  String? selectedGroupId;
  List<dynamic> groups = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  // Function to fetch groups from the API
  Future<void> fetchGroups() async {
    try {
      final groupList = await apiService.getGroups();
      setState(() {
        groups = groupList;
      });
    } catch (e) {
      print("Error fetching groups: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load groups")),
      );
    }
  }

  // Function to handle the registration logic
  void registerUser() {
    setState(() {
      phoneNumber = phoneController.text;
      firstName = firstNameController.text;
      lastName = lastNameController.text;
      email = emailController.text;
      designation = designationController.text;
      password = passwordController.text;

      print("User registered with following data:");
      print("Phone: $phoneNumber");
      print("First Name: $firstName");
      print("Last Name: $lastName");
      print("Email: $email");
      print("Designation: $designation");
      print("Password: $password");
      print("Group ID: $selectedGroupId");

      apiService.registerUser(phoneNumber, firstName, lastName, email, designation, password,selectedGroupId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User registered successfully!")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Registration"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Phone Number
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 10),

              // First Name
              TextField(
                controller: firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              SizedBox(height: 10),

              // Last Name
              TextField(
                controller: lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              SizedBox(height: 10),

              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),

              // Designation
              TextField(
                controller: designationController,
                decoration: InputDecoration(labelText: 'Designation'),
              ),
              SizedBox(height: 10),

              // Password
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,  // Hide password
              ),
              SizedBox(height: 20),

              // Group Dropdown
              if (groups.isNotEmpty)
                DropdownButton<String>(
                  hint: Text('Select Group'),
                  value: selectedGroupId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGroupId = newValue;
                    });
                  },
                  items: groups.map<DropdownMenuItem<String>>((group) {
                    return DropdownMenuItem<String>(
                      value: group['id'].toString(),
                      child: Text(group['name']),
                    );
                  }).toList(),
                ),
              SizedBox(height: 20),

              // Register Button
              ElevatedButton(
                onPressed: registerUser,
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
