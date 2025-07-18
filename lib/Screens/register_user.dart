import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:samparka/Screens/upload_kr_excel.dart';
import 'package:samparka/Service/api_service.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

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
  String? selectedKaryakarthaId;

  String? selectedShreni;
  List<String> shrenis = ["Administration","Art and Award Winners","Economic","Healthcare","Intellectuals","Law and Judiciary","Religious","Science and Research","Social Leaders and Organizations","Sports"];

  List<dynamic> groups = [];
  late List<dynamic> result;
  List<dynamic> members = [];
  List<dynamic> supervisor = [];

  List<String> states = ['Karnataka South', 'Maharashtra', 'Tamil Nadu'];
  List<String> districts = []; // Will be populated based on the selected state
  List<String> cities = [];

  String? selectedState;
  String? selectedDistrict;
  String? selectedCity = 'None';
  String? userType = 'KR';

  bool isLoading = false;
  bool isTestUser = false;

  Map<String, List<String>> stateDistricts = {
    'Karnataka South': ['Bangalore Mahanagara', 'Mysuru Mahanagara'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
  };

  Map<String, List<String>> districtCities = {
    'Bangalore': ['Whitefield', 'Koramangala', 'Electronic City'],
    'Mysuru Mahanagara': ['Vijayanagar', 'Nazarbad', 'Gokulam'],
    'Mangalore': ['Pandeshwar', 'Bajpe', 'Kankanady'],
    'Mumbai': ['Andheri', 'Bandra', 'Juhu'],
    'Pune': ['Kothrud', 'Hinjewadi', 'Wakad'],
    'Nagpur': ['Civil Lines', 'Gandhi Baug', 'Ajni'],
    'Chennai': ['T Nagar', 'Adyar', 'Besant Nagar'],
    'Coimbatore': ['R S', 'Peelamedu', 'Ganapathy'],
    'Madurai': ['KK Nagar', 'Anna Nagar', 'Tallakulam'],
  };

  @override
  void initState() {
    super.initState();
    fetchGroups();
    fetchSupervisor();
    if(apiService.UserId.startsWith('TKR')){
      userType = "TKR";
      isTestUser = true;
    }
    //fetchMembers();
    setState(() {});
  }

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

  Future<void> fetchMembers() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.myTeam(0, 100);
      if (result.isEmpty) {
        setState(() {
          selectedKaryakarthaId = apiService.UserId;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('No ShreniPramuhk to assign \n defualting to self:${apiService.first_name}'),
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
        print('members $result');
        members = result;
      });
    } catch (e) {
      print("Error fetching influencers: $e");
    }
  }

  Future<void> fetchSupervisor() async {
    try {
      result = await apiService.mySupervisor();
      setState(() {
        print('Supervisor $result');
        supervisor = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load Supervisor")),
      );
      print("Failed to load Supervisor: $e");
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
      phoneNumber = phoneController.text.trim();
      firstName = firstNameController.text.trim();
      lastName = lastNameController.text.trim();
      email = emailController.text.trim();
      designation = designationController.text.trim();
      password = passwordController.text.trim();

      int? groupIndex = int.tryParse(selectedGroupId ?? '');
      if (groupIndex != null && groups[groupIndex]['name'] == "ADMIN") {
        userType = "AD";
      }
      if (isTestUser) {
        userType = "TKR";
      }

      // Construct registration data list
      List<dynamic> registrationData = [
        phoneNumber,          // 0
        firstName,            // 1
        lastName,             // 2
        email,                // 3
        designation,          // 4
        password,             // 5
        selectedGroupId,      // 6
        selectedKaryakarthaId,// 7
        _image,               // 8
        selectedCity,         // 9
        selectedDistrict,     // 10
        selectedState,        // 11
        selectedShreni,       // 12
        userType,             // 13
      ];

      // Validate all fields
      bool isValid = registrationData.every((item) {
        if (item == null) return false;
        if (item is String && item.trim().isEmpty) return false;
        return true;
      });

      // Show error if invalid
      if (!isValid) {
        if (_image == null || phoneNumber.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty || designation.isEmpty || password.isEmpty || selectedGroupId == null || selectedCity == null || selectedDistrict == null || selectedState == null || selectedShreni == null) {
          String errorMessage = _image == null ? "Please upload profile picture." : "Please fill all fields.";

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

      }

      print("User registered with following data:");
      print("$phoneNumber $firstName $lastName $email $designation $password $selectedKaryakarthaId $selectedGroupId $userType");

      // Proceed with API call
      apiService.registerUser(registrationData);

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
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        //title: Text("User Registration"),
        title: Text(" "),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space between the columns
                    children: [
                      // First Column: "Add New" and "Influencer"
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align the text to the start
                        children: [
                          Text(
                            "Register New",
                            style: TextStyle(
                              fontSize: largeFontSize,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromRGBO(5, 50, 70, 1.0),
                            ),
                          ),
                          Text(
                            "Karyakartha",
                            style: TextStyle(
                              fontSize: largeFontSize * 2,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(5, 50, 70, 1.0),
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: SizedBox()),
                      // Second Column: Button with Upload and Rotated Arrow Icon (pushed to the right)
                      if (!apiService.UserId.startsWith('TKR'))
                        Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color.fromRGBO(16, 115, 65, 1.0),
                              Color.fromRGBO(60, 170, 145, 1.0)
                            ],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,  // Align the button to the right
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UploadKRExcel()),
                                );
                              },
                              style: TextButton.styleFrom(
                                //backgroundColor: Colors.blue, // Background color for the button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // Rounded corners for the button
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center, // Center the row content inside the button
                                  children: [
                                    Text(
                                      'Upload Excel',
                                      style: TextStyle(
                                        fontSize: normFontSize,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),  // Add space between the text and the image
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
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (apiService.phone == '7337620623' || apiService.UserId.startsWith('TKR'))
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isTestUser ? 'Creating Test Karyakartha' : 'Create Test Karyakartha?',
                              style: TextStyle(fontSize: 18,color: Colors.red,fontWeight: FontWeight.bold),
                            ),
                            if (apiService.phone == '7337620623')
                              Switch(
                                value: isTestUser,
                                onChanged: (bool newValue) {
                                  setState(() {
                                    isTestUser = newValue;
                                  });
                                },
                                activeColor: Colors.red,
                              ),
                          ],
                        ),
                      ],
                    ),
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
                  _buildTextField(hint: "Phone Number", controller: phoneController),
                  SizedBox(height: 10),
                  // First Name
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(hint: "First Name", controller: firstNameController),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(hint: "Last Name", controller: lastNameController),
                      ),
                    ],
                  ),
                  // Email
                  const SizedBox(height: 16),
                  _buildTextField(hint: "E-mail Address", controller: emailController),
                  const SizedBox(height: 16),
                  _buildTextField(hint: "Designation", controller: designationController),
                  SizedBox(height: 20),
                  // Group Dropdown
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
                        child: Text(groups.isNotEmpty ? 'Select Group' : 'Loading groups..'),
                      ),
                      value: selectedGroupId,
                      onChanged: (String? newValue) async {
                        if (newValue == '1'){
                          fetchMembers();
                        }
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
                  if (selectedGroupId=='1')
                    SizedBox(height: 20),
                  if (selectedGroupId=='1')
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
                          child: Text(members.isNotEmpty ? 'Select ShreniPramuhk' : 'Loading ShreniPramuhk..'),
                        ),
                        value: selectedKaryakarthaId,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedKaryakarthaId = newValue;
                          });
                        },
                        items: members.map<DropdownMenuItem<String>>((member) {
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
                  if (selectedGroupId=='1'|| selectedGroupId=='2')
                    SizedBox(height: 20),
                  //Shreni
                  if (selectedGroupId=='1' || selectedGroupId=='2')
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade400, width: 1.0),
                    ),
                    child: DropdownButton<String>(
                      hint: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Select Shreni'),
                      ),
                      value: selectedShreni,
                      onChanged: (String? newShreni) {
                        setState(() {
                          selectedShreni = newShreni;
                        });
                      },
                      items: shrenis.map<DropdownMenuItem<String>>((shreni) {
                        return DropdownMenuItem<String>(
                          value: shreni,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(shreni),
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      underline: Container(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade400, width: 1.0),
                    ),
                    child: DropdownButton<String>(
                      hint: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Select State'),
                      ),
                      value: selectedState,
                      onChanged: (String? newState) {
                        setState(() {
                          selectedState = newState;
                          selectedDistrict = null; // Reset district when state changes
                          selectedCity = null; // Reset city when district changes
                          districts = stateDistricts[selectedState] ?? [];
                        });
                      },
                      items: states.map<DropdownMenuItem<String>>((state) {
                        return DropdownMenuItem<String>(
                          value: state,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(state),
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      underline: Container(),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (selectedState != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade400, width: 1.0),
                      ),
                      child: DropdownButton<String>(
                        hint: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Select District'),
                        ),
                        value: selectedDistrict,
                        onChanged: (String? newDistrict) {
                          setState(() {
                            selectedDistrict = newDistrict;
                            selectedCity = null; // Reset city when district changes
                            cities = districtCities[newDistrict] ?? [];
                          });
                        },
                        items: districts.map<DropdownMenuItem<String>>((district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(district),
                            ),
                          );
                        }).toList(),
                        isExpanded: true,
                        underline: Container(),
                      ),
                    ),
                  SizedBox(height: 20),
                  // City Dropdown (Depends on the selected district)
                  /*
                  if (selectedDistrict != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade400, width: 1.0),
                      ),
                      child: DropdownButton<String>(
                        hint: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Select City'),
                        ),
                        value: selectedCity,
                        onChanged: (String? newCity) {
                          setState(() {
                            selectedCity = newCity;
                          });
                        },
                        items: cities.map<DropdownMenuItem<String>>((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(city),
                            ),
                          );
                        }).toList(),
                        isExpanded: true,
                        underline: Container(),
                      ),
                    ),*/
                  SizedBox(height: 20),
                  // Display selected values
                  if (selectedState != null && selectedDistrict != null && selectedCity != null)
                    Text(
                      'Selected State: $selectedState\nSelected District: $selectedDistrict\nSelected City: $selectedCity',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
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
                      onPressed: () {
                        setState(() {
                          isLoading = true; // Show loading indicator
                        });
                        registerUser();
                        setState(() {
                          isLoading = false; // Hide loading indicator
                        });
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
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isLoading)
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
  Widget _buildTextField({required String hint,required TextEditingController controller}) {
    return TextField(
      controller: controller,
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
