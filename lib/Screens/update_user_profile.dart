import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Service/api_service.dart';

class UpdateUserPage extends StatefulWidget {
  final String id;

  UpdateUserPage(this.id);

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final apiService = ApiService();
  final _picker = ImagePicker();

  File? _image;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController designationController = TextEditingController();

  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String designation = '';
  String? selectedGroupId;
  String? selectedShreniId;
  late String KR_id = '';

  List<dynamic> groups = [];
  late List<dynamic> result;
  List<dynamic> members = [];
  List<dynamic> supervisor = [];

  List<String> states = ['Karnataka South', 'Maharashtra', 'Tamil Nadu'];
  List<String> districts = [];
  List<String> cities = [];

  String? selectedState;
  String? selectedDistrict;
  String? selectedCity;

  bool isLoading = false;

  Map<String, List<String>> stateDistricts = {
    'Karnataka South': ['Bangalore Mahanagara', 'Mysuru Mahanagara'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
  };

  Map<String, List<String>> districtCities = {
    'Bangalore Mahanagara': ['Whitefield', 'Koramangala', 'Electronic City'],
    'Mysuru Mahanagara': ['Vijayanagar', 'Nazarbad', 'Gokulam'],
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
    KR_id = widget.id;
    fetchGroups();
    fetchSupervisor();
    getKaryakartha();
  }

  Future<void> fetchGroups() async {
    try {
      final groupList = await apiService.getGroups();
      setState(() {
        groups = groupList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load groups")),
      );
    }
  }

  Future<void> fetchMembers() async {
    try {
      result = await apiService.myTeam(0, 100);
      if (result.isEmpty) {
        setState(() {
          selectedShreniId = apiService.UserId;
        });
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Alert'),
            content: Text('No ShreniPramukh to assign\nDefaulting to self: ${apiService.first_name}'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
      result.add({'id': apiService.UserId, 'first_name': 'self(${apiService.first_name})', 'last_name': ''});
      setState(() {
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
        supervisor = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load Supervisor")),
      );
    }
  }

  Future<void> getKaryakartha() async {
    try {
      result = await apiService.getKaryakartha(KR_id);
      print("KR details: $result");

      final fetchedState = result[0]['state'];
      final fetchedDistrict = result[0]['district'];
      final fetchedCity = result[0]['city'];

      setState(() {
        firstNameController.text = result[0]['first_name'] ?? '';
        lastNameController.text = result[0]['last_name'] ?? '';
        designationController.text = result[0]['designation'] ?? '';
        phoneController.text = result[0]['phone_number'] ?? '';
        emailController.text = result[0]['email'] ?? '';

        // Validate and set state
        if (states.contains(fetchedState)) {
          selectedState = fetchedState;
          districts = stateDistricts[selectedState] ?? [];

          // Validate and set district
          if (districts.contains(fetchedDistrict)) {
            selectedDistrict = fetchedDistrict;
            cities = districtCities[selectedDistrict] ?? [];

            // Validate and set city
            if (cities.contains(fetchedCity)) {
              selectedCity = fetchedCity;
            } else {
              selectedCity = null;
            }
          } else {
            selectedDistrict = null;
            selectedCity = null;
          }
        } else {
          selectedState = null;
          selectedDistrict = null;
          selectedCity = null;
        }
      });
    } catch (e) {
      print("Error fetching user: $e");
    }
  }


  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void updateUser() async {
    setState(() {
      phoneNumber = phoneController.text;
      firstName = firstNameController.text;
      lastName = lastNameController.text;
      email = emailController.text;
      designation = designationController.text;
    });

    if ([phoneNumber, firstName, lastName, email, designation].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all the fields")),
      );
      return;
    }

    List<dynamic> updateData = [
      phoneNumber,
      firstName,
      lastName,
      email,
      designation,
      null, // password removed
      selectedGroupId,
      selectedShreniId,
      _image,
      selectedCity,
      selectedDistrict,
      selectedState,
    ];

    try {
      setState(() {
        isLoading = true;
      });

      await apiService.updateUser(updateData, widget.id);

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User updated successfully!")),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update user")),
      );
      print("Error updating user: $e");
    }
  }

  Widget _buildTextField({required String hint, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    designationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update User')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile image
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400, width: 1.0),
                        ),
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.20,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _image != null ? FileImage(_image!) : null,
                          child: _image == null
                              ? Icon(Icons.person, color: Colors.white, size: 80)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Color.fromRGBO(5, 50, 70, 1.0),
                          child: IconButton(
                            icon: Icon(_image != null ? Icons.edit : Icons.add, color: Colors.white),
                            onPressed: () {
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
                      if (_image != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.red,
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

                SizedBox(height: 16),
                _buildTextField(hint: "Phone Number", controller: phoneController),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTextField(hint: "First Name", controller: firstNameController)),
                    SizedBox(width: 16),
                    Expanded(child: _buildTextField(hint: "Last Name", controller: lastNameController)),
                  ],
                ),
                SizedBox(height: 16),
                _buildTextField(hint: "E-mail Address", controller: emailController),
                SizedBox(height: 16),
                _buildTextField(hint: "Designation", controller: designationController),
                SizedBox(height: 20),

                // Group Dropdown
                buildDropdownContainer(
                  hint: groups.isNotEmpty ? 'Select Group' : 'Loading groups..',
                  value: selectedGroupId,
                  items: groups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group['id'].toString(),
                      child: Text(group['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == '1') fetchMembers();
                    setState(() => selectedGroupId = value);
                  },
                ),

                if (selectedGroupId == '1') ...[
                  SizedBox(height: 20),
                  buildDropdownContainer(
                    hint: members.isNotEmpty ? 'Select ShreniPramukh' : 'Loading...',
                    value: selectedShreniId,
                    items: members.map((member) {
                      return DropdownMenuItem<String>(
                        value: member['id'].toString(),
                        child: Text('${member['first_name']} ${member['last_name']}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedShreniId = value),
                  ),
                ],

                SizedBox(height: 20),
                buildDropdownContainer(
                  hint: 'Select State',
                  value: selectedState,
                  items: states.map((state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                      selectedDistrict = null;
                      selectedCity = null;
                      districts = stateDistricts[selectedState] ?? [];
                    });
                  },
                ),

                if (selectedState != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: buildDropdownContainer(
                      hint: 'Select District',
                      value: selectedDistrict,
                      items: districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDistrict = value;
                          selectedCity = null;
                          cities = districtCities[selectedDistrict] ?? [];
                        });
                      },
                    ),
                  ),

                if (selectedDistrict != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: buildDropdownContainer(
                      hint: 'Select City',
                      value: selectedCity,
                      items: cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedCity = value),
                    ),
                  ),

                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isLoading ? null : updateUser,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Update Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownContainer({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade400, width: 1.0),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: Container(),
        hint: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(hint)),
        value: value,
        onChanged: onChanged,
        items: items,
      ),
    );
  }
}
