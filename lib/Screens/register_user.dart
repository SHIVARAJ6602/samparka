import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:samparka/Service/api_service.dart';

class RegisterUserPage extends StatefulWidget {

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUserPage> {

  final apiService = ApiService();

  File? _image;  // This will store the selected image
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);  // Update the state with the picked image
      });
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
              //profile Pic
              Center(
                child: Stack(
                  alignment: Alignment.center, // Center the CircleAvatar within the Stack
                  children: [
                    // The main CircleAvatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Ensures the container is circular
                        border: Border.all(
                          color: Colors.grey.shade400, // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.20,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _image != null ? FileImage(_image!) : null,  // If an image is picked, display it
                        child: _image == null
                            ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.width * 0.34,
                        )
                            : null,
                      ),
                    ),
                    // add or edit image Button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Color.fromRGBO(5, 50, 70, 1.0), // Background color of the plus icon
                        child: IconButton(
                          icon: Icon(_image != null? Icons.edit: Icons.add, color: Colors.white),
                          onPressed: () async {
                            // Show a dialog to choose between camera or gallery
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.camera_alt),
                                    title: Text('Take a Photo'),
                                    onTap: () {
                                      _pickImage(ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.photo_library),
                                    title: Text('Pick from Gallery'),
                                    onTap: () {
                                      _pickImage(ImageSource.gallery);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    //Delete Button
                    if (_image != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.red, // Background color of the plus icon
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.white,size: 20,),
                            onPressed: () {
                              setState(() {
                                _image = null;
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Phone Number
              const SizedBox(height: 16),
              _buildTextField(hint: "Phone Number"),
              SizedBox(height: 10),
              // First Name
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(hint: "First Name"),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(hint: "Last Name"),
                  ),
                ],
              ),
              // Email
              const SizedBox(height: 16),
              _buildTextField(hint: "E-mail Address"),
              const SizedBox(height: 16),
              _buildTextField(hint: "Designation"),
              SizedBox(height: 20),
              // Group Dropdown
              if (groups.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    border: Border.all(
                      color: Colors.grey.shade400, // Border color when not focused
                      width: 1.0, // Border width
                    ),
                  ),
                  child: DropdownButton<String>(
                    hint: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Select Group'),
                    ),
                    value: selectedGroupId,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroupId = newValue;
                      });
                    },
                    items: groups.map<DropdownMenuItem<String>>((group) {
                      return DropdownMenuItem<String>(
                        value: group['id'].toString(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(group['name']),
                        ),
                      );
                    }).toList(),
                    isExpanded: true, // Ensures the dropdown stretches to the full width
                    underline: Container(), // Removes the default underline from the dropdown
                  ),
                ),
              SizedBox(height: 20),
              // Register Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.fromRGBO(2, 40, 60, 1),
                      Color.fromRGBO(60, 170, 145, 1.0)
                    ],
                  ),
                ),
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 10), // Adjust padding
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,  // Center the row content
                      children: [
                        const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),  // Add space between the text and the image
                        Transform.rotate(
                          angle: 4.7124,  // Rotate the arrow 90 degrees
                          child: Image.asset(
                            'assets/icon/arrow.png',
                            color: Colors.white,
                            width: 15,  // Adjust the size of the image
                            height: 15, // Adjust the size of the image
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTextField({required String hint}) {
    return TextField(
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
