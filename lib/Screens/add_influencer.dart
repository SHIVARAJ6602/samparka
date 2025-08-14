import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:samparka/Screens/home.dart';
import 'package:samparka/Screens/upload_gv_excel.dart';
import 'package:flutter/services.dart';


import '../Service/api_service.dart';
import 'migrate_influencer.dart';

class AddInfluencerPage extends StatefulWidget {
  const AddInfluencerPage({super.key});

  @override
  _AddInfluencerPageState createState() => _AddInfluencerPageState();
}

class _AddInfluencerPageState extends State<AddInfluencerPage> {
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
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController state1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController city2Controller = TextEditingController();
  final TextEditingController district2Controller = TextEditingController();
  final TextEditingController state2Controller = TextEditingController();
  final TextEditingController soochiController = TextEditingController();
  final TextEditingController shreniController = TextEditingController();

  TextEditingController _myController = TextEditingController();

  String? selectedShreni;
  List<String> shrenis = ["Administration","Art and Award Winners","Economic","Healthcare","Intellectuals","Law and Judiciary","Religious","Science and Research","Social Leaders and Organizations","Sports"];
  String? selectedSoochi;
  List<String> soochis = ["AkhilaBharthiya","JillaSampark","PranthyaSampark"];
  String? selectedInteractionLevel;
  List<String> interactionLevels = ["Sahabhag","Sahavas","Samarthan","Sampark"];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);  // Update the state with the picked image
      });
    }
  }

  late List<dynamic> result;
  List<dynamic> karyakartha = [];
  List<dynamic> hashtags = [];
  List<dynamic> selectedHashtags = [];
  Set<int> selectedHashtagsIDs = {};
  String? selectedKaryakarthaId;
  bool isTest = false;

  void toggleHashtagSelection(int id) {
    setState(() {
      if (selectedHashtagsIDs.contains(id)) {
        selectedHashtagsIDs.remove(id);  // Deselect
      } else {
        selectedHashtagsIDs.add(id);  // Select
      }
      getSelectedHashtags();
      //log("selected hashtag IDs: $selectedHashtagsIDs , selected hashtags: $selectedHashtags");
    });
  }

  // Function to get the list of selected hashtags (with names)
  void getSelectedHashtags() {
    // Store the names of selected hashtags only
    selectedHashtags = hashtags
        .where((hashtag) {
      return selectedHashtagsIDs.contains(hashtag['id']);
    })
        .map((hashtag) => hashtag['name'])
        .toList();

    // Optionally, log or store the selected hashtag names
    //log("Selected Hashtags Names: $selectedHashtags");
  }

  Future<void> fetchShreni() async {
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
        //log('karyakartha\'s $result');
        karyakartha = result;
      });
    } catch (e) {
      log("Error fetching karyakarthas: $e");
    }
  }

  Future<void> fetchHashtags() async {
    try {
      // Call the apiService.homePage() and store the result
      result = await apiService.getHashtags();
      setState(() {
        hashtags = result;
        //log('hastags\'s $result');
      });
    } catch (e) {
      log("Error fetching tags: $e");
    }
  }

  void addHashtagDialog() {
    // Text editing controller to take input from user
    TextEditingController newHashtagController = TextEditingController();

    // Show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Hashtag'),
          content: TextField(
            controller: newHashtagController,
            decoration: InputDecoration(hintText: 'Enter new hashtag name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                String newHashtagName = newHashtagController.text.trim();
                if (newHashtagName.isNotEmpty) {
                  // Create a new hashtag map with an incremented ID
                  setState(() {
                    hashtags.add({
                      'id': hashtags.length + 1, // Simple way to increment ID
                      'name': newHashtagName,
                    });
                    //log('updated hastags: $hashtags');
                  });
                }
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without adding
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
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
    if(apiService.UserId.startsWith('TKR')){
      isTest = true;
    }

    if(apiService.lvl>2){
      fetchShreni();
    }
    fetchHashtags();
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

  void registerInfluencer() async {
    // Validate all required fields
    if (_image == null ||
        fnameController.text.trim().isEmpty ||
        lnameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        designationController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        organizationController.text.trim().isEmpty ||
        impactOnSocietyController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        districtController.text.trim().isEmpty ||
        state1Controller.text.trim().isEmpty ||
        selectedHashtagsIDs.isEmpty ||
        selectedShreni == null ||
        selectedSoochi == null ||
        selectedInteractionLevel == null ||
        (apiService.lvl > 2 && selectedKaryakarthaId == null)) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all required fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Continue if all validations pass
    List<dynamic> registrationData = [
      phoneController.text.trim(),
      fnameController.text.trim(),
      lnameController.text.trim(),
      emailController.text.trim(),
      designationController.text.trim(),
      descriptionController.text.trim(),
      selectedHashtags,
      organizationController.text.trim(),
      impactOnSocietyController.text.trim(),
      selectedInteractionLevel,
      addressController.text.trim(),
      cityController.text.trim(),
      districtController.text.trim(),
      state1Controller.text.trim(),
      _image,
      selectedKaryakarthaId,
      selectedShreni,
      selectedSoochi,
      isTest,
    ];

    try {
      bool success = await apiService.createGanyaVyakthi(context, registrationData);
      String message = success ? "Registered successfully!" : "Failed to register!";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      //log("Error during registration: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space between the columns
              children: [
                // First Column: "Add New" and "Influencer"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align the text to the start
                  children: [
                    Text(
                      "Add New",
                      style: TextStyle(
                        fontSize: largeFontSize,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                    ),
                    AutoSizeText(
                      "Influencer",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: largeFontSize * 2,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(5, 50, 70, 1.0),
                      ),
                      minFontSize: largeFontSize.floorToDouble(),
                      stepGranularity: 1.0,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                // Second Column: Button with Upload and Rotated Arrow Icon (pushed to the right)
                /*if (!apiService.UserId.startsWith('TKR'))
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromRGBO(16, 115, 65, 1.0),
                          Color.fromRGBO(60, 170, 145, 1.0),
                        ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UploadGVExcel()),
                          );
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Upload',
                                style: TextStyle(
                                  fontSize: normFontSize,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Transform.rotate(
                                angle: 4.7124,
                                child: Image.asset(
                                  'assets/icon/arrow.png',
                                  color: Colors.white,
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                */
              ],
            ),
            if (apiService.phone == '7337620623' || apiService.UserId.startsWith('TKR'))
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isTest ? 'Creating Test Influencer' : 'Create Test Influencer?',
                        style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      if (apiService.phone == '7337620623')
                        Switch(
                          value: isTest,
                          onChanged: (bool newValue) {
                            setState(() {
                              isTest = newValue;
                            });
                          },
                          activeColor: Colors.red,
                        ),
                    ],
                  ),
                ],
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
            // f and l name
            Row(
              children: [
                Expanded(
                  child: _buildTextField(hint: "First Name", controller: fnameController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(hint: "Last Name", controller: lnameController),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(hint: "Phone Number", controller: phoneController),
            const SizedBox(height: 16),
            _buildTextField(hint: "Designation", controller: designationController),
            const SizedBox(height: 16),
            _buildTextField(hint: "Organization", controller: organizationController),
            const SizedBox(height: 16),
            _buildTextField(hint: "Impact On Society", controller: impactOnSocietyController),
            const SizedBox(height: 16),
            _buildTextField(hint: "Short description", controller: descriptionController),
            const SizedBox(height: 16),
            //Shreni
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
            const SizedBox(height: 16),
            //Soochi
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade400, width: 1.0),
              ),
              child: DropdownButton<String>(
                hint: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Select Soochi'),
                ),
                value: selectedSoochi,
                onChanged: (String? newSoochi) {
                  setState(() {
                    selectedSoochi = newSoochi;
                    //log(selectedSoochi!+selectedInteractionLevel!+selectedShreni!);
                  });
                },
                items: soochis.map<DropdownMenuItem<String>>((soochi) {
                  return DropdownMenuItem<String>(
                    value: soochi,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(soochi),
                    ),
                  );
                }).toList(),
                isExpanded: true,
                underline: Container(),
              ),
            ),
            const SizedBox(height: 16),
            //Level of Interaction
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade400, width: 1.0),
              ),
              child: DropdownButton<String>(
                hint: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Select Interaction Level'),
                ),
                value: selectedInteractionLevel,
                onChanged: (String? newSoochi) {
                  setState(() {
                    selectedInteractionLevel = newSoochi;
                  });
                },
                items: interactionLevels.map<DropdownMenuItem<String>>((interactionLevel) {
                  return DropdownMenuItem<String>(
                    value: interactionLevel,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(interactionLevel),
                    ),
                  );
                }).toList(),
                isExpanded: true,
                underline: Container(),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(hint: "E-mail Address(optional)", controller: emailController),
            const SizedBox(height: 16),
            // Hashtag Section
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Wrap the tags in a Row to keep them in a single horizontal line
                  if (hashtags.isNotEmpty)
                    Row(
                      children: List.generate(hashtags.length, (index) {
                        bool isSelected = selectedHashtagsIDs.contains(hashtags[index]['id']);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              toggleHashtagSelection(hashtags[index]['id']);  // Toggle selection on tap
                            },
                            child: Chip(
                              label: Text(hashtags[index]['name']),
                              backgroundColor: isSelected ? Colors.green : Colors.blue[50],
                            ),
                          ),
                        );
                      }),
                    ),
                  const SizedBox(width: 8),
                  if(apiService.lvl>2)
                  ElevatedButton(
                    onPressed: () {
                      // Open the dialog to add a new hashtag
                      addHashtagDialog();
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
                ],
              ),
            ),
            //Address
            const SizedBox(height: 24),
            _buildTextField(hint: "Address", controller: addressController),
            //city and district
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(hint: "City", controller: cityController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(hint: "District", controller: districtController),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(hint: "State", controller: state1Controller),
            //shreni
            if(apiService.lvl>2)
              Container(
                child: Column(
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
                          child: Text(
                            karyakartha.isNotEmpty
                                ? 'Assign Karyakartha'
                                : 'Loading Karyakartha\'s..',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                        value: selectedKaryakarthaId,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedKaryakarthaId = newValue;
                          });
                        },
                        items: karyakartha.map<DropdownMenuItem<String>>((member) {
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
              ),
            const SizedBox(height: 16),
            //Register Button
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
                  registerInfluencer();

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

  Widget _buildTextField({required String hint, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: controller.text.isNotEmpty ? hint : null,
        hintText: controller.text.isNotEmpty ? null : hint,
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.shade600,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1.0,
          ),
        ),
      ),
      onChanged: (_) {
        // Force rebuild to update label visibility
        // You'll need to call setState in the parent where this widget is used
        _myController.addListener(() {
          setState(() {}); // Rebuild to show/hide label dynamically
        });
      },
    );
  }
}
