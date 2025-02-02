import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:samparka/Screens/home.dart';

import '../Service/api_service.dart';

class AddInfluencer1Page extends StatefulWidget {
  const AddInfluencer1Page({super.key});

  @override
  _AddInfluencer1PageState createState() => _AddInfluencer1PageState();
}

class _AddInfluencer1PageState extends State<AddInfluencer1Page> {
  // This keeps track of the currently selected bottom navigation item.
  int _selectedIndex = 1;

  final apiService = ApiService();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Controllers for each input field
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController assignedKaryakartaPhoneController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hashtagsController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController impactOnSocietyController = TextEditingController();
  final TextEditingController interactionLevelController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController city1Controller = TextEditingController();
  final TextEditingController district1Controller = TextEditingController();
  final TextEditingController state1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController city2Controller = TextEditingController();
  final TextEditingController district2Controller = TextEditingController();
  final TextEditingController state2Controller = TextEditingController();

  /// Regex for validation
  final RegExp nameRegex = RegExp(r'^[A-Za-z]{1,50}$');
  final RegExp designationRegex = RegExp(r'^[A-Za-z., ]{1,50}$');
  final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp phoneRegex = RegExp(r'^\d{10}$');

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);  // Update the state with the picked image
      });
    }
  }

  late List<dynamic> result;
  List<dynamic> shreni = [];
  String? selectedShreniId;

  Future<void> fetchShreni() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.myTeam(0, 100);
      if (result.isEmpty) {
        setState(() {
          selectedShreniId = apiService.UserId;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('No ShreniPramukh to assign \n defualting to self:${apiService.first_name}'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
      result.add({'id': apiService.UserId,'first_name': 'self(${apiService.first_name})','last_name': ''});
      setState(() {
        print('shreni\'s $result');
        shreni = result;
      });
    } catch (e) {
      print("Error fetching influencers: $e");
    }
  }

  void _onNavItemTapped(int index) {
    if (index == 0) {
      // Navigate to InfluencersPage when the 0th index is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InfluencersPage()),
      );
    } else {
      // Update the selected index for other tabs
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if(apiService.lvl>2){
      fetchShreni();
    }
    // Initialize formData with default values if necessary
    Map<String, dynamic> formData = {
      "action": "CreateGanyaVyakti",
      "fname": "",
      "lname": "",
      "phone_number": "",
      "assigned_karyakarta_phone_number": "",
      "designation": "",
      "description": "",
      "hashtags": "",
      "organization": "",
      "email": "",
      "impact_on_society": "",
      "interaction_level": "",
      "address": "",
      "city": "",
      "district": "",
      "state": "",
      "address_2": "",
      "city_2": "",
      "district_2": "",
      "state_2": ""
    };
  }

  void registerInfluencer() {
    setState(() {

      List<dynamic> registrationData = [
        phoneController.text,//0
        fnameController.text,//1
        lnameController.text,//2
        emailController.text,//3
        designationController.text,//4
        descriptionController.text,//5
        hashtagsController.text,//6
        organizationController.text,//7
        impactOnSocietyController.text,//8
        interactionLevelController.text,//9
        address1Controller.text,//10
        city1Controller.text,//11
        district1Controller.text,//12
        state1Controller.text,//13
        _image!,//14
      ];

      apiService.CreateGanyaVyakthi(registrationData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User registered successfully!")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar background transparent
        elevation: 0, // Remove the app bar shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(5, 50, 70, 1.0)), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            const Text(
              "Add New",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(5, 50, 70, 1.0),
              ),
            ),
            const Text(
              "Influencer",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(5, 50, 70, 1.0),
              ),
            ),
            //influencer image
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
                        width: 1.0,
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
                        radius: 20,
                        backgroundColor: Colors.red, // Background color of the plus icon
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white),
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
            const SizedBox(height: 24),
            // Input Fields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(hint: "First Name",
                      controller: fnameController ,
                      regex: nameRegex,
                      errorMessage: "Only alphabets allowed (Max 50 chars)" ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(hint: "Last Name",
                      controller: lnameController,
                      regex: nameRegex,
                      errorMessage: "Only alphabets allowed (Max 50 chars)" ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(hint: "Designation", controller: designationController,
                regex: designationRegex,
                errorMessage: "Invalid Designation" ),
            const SizedBox(height: 16),
            _buildTextField(hint: "E-mail (example@gmail.com) ", controller: emailController,
                regex: emailRegex,
                errorMessage: "Invalid E-mail format"),
            const SizedBox(height: 16),
            _buildTextField(hint: "+91 | Phone Number", controller: phoneController,
                regex: phoneRegex,
                errorMessage: "Enter a valid 10-digit phone number",
                maxLength: 10),
            const SizedBox(height: 16),
            // Hashtag Section
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,  // Make the Row scrollable horizontally
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add hashtag functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "+ Add Hashtags",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Wrap the tags in a Row instead of Wrap to keep them in a single horizontal line
                  Row(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text("#Hash${index + 1}"),
                          backgroundColor: Colors.blue[50],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(hint: "Address", controller: address1Controller, regex: nameRegex),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(hint: "City", controller: city1Controller),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(hint: "District", controller: district1Controller),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(hint: "State", controller: state1Controller),
            /*const SizedBox(height: 16),
            _buildTextField(hint: "Address 2", controller: address2Controller),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(hint: "City", controller: city2Controller),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(hint: "District", controller: district2Controller),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(hint: "State", controller: state2Controller),*/
            //shreni
            if(apiService.lvl>2)
              Column(
                children: [
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.0, // Border width
                      ),
                    ),
                    child: DropdownButton<String>(
                      hint: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(shreni.isNotEmpty ? 'Select ShreniPramukh' : 'Loading ShreniPramukh..'),
                      ),
                      value: selectedShreniId,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedShreniId = newValue;
                        });
                      },
                      items: shreni.map<DropdownMenuItem<String>>((member) {
                        return DropdownMenuItem<String>(
                          value: member['id'].toString(),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('${member['first_name']} ${member['last_name']}'),
                          ),
                        );
                      }).toList(),
                      isExpanded: true, // Ensures the dropdown stretches to the full width
                      underline: Container(), // Removes the default underline from the dropdown
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
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
                onPressed: () {

                },
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
            const SizedBox(height: 32),
            // SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required TextEditingController controller, RegExp? regex, String? errorMessage, int? maxLength}) {
    return TextFormField(
      controller: controller, // Assign the dynamic controller
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
      keyboardType: hint == "Phone Number" ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        if (hint == "Phone Number") ...[
          FilteringTextInputFormatter.digitsOnly, // Restrict to numbers
          LengthLimitingTextInputFormatter(maxLength), // Restrict length
        ],
      ],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) return "Field cannot be empty";
        if (regex != null && !regex.hasMatch(value)) return errorMessage;
        return null;
      },
    );
  }
}
