import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:samparka/Screens/home.dart';

import '../Service/api_service.dart';

class ChangeRequestPage extends StatefulWidget {

  final String id;

  ChangeRequestPage(this.id);

  @override
  _ChangeRequestPageState createState() => _ChangeRequestPageState();
}

class _ChangeRequestPageState extends State<ChangeRequestPage> {
  // This keeps track of the currently selected bottom navigation item.
  int _selectedIndex = 1;

  final apiService = ApiService();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String profileImage = '';

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
  final TextEditingController IOSController = TextEditingController();
  final TextEditingController organisationController = TextEditingController();
  final TextEditingController soochiController = TextEditingController();
  final TextEditingController shreniController = TextEditingController();

  TextEditingController _myController = TextEditingController();

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
  String? selectedKaryakarthaId;

  String? selectedShreni;
  List<String> shrenis = ["Administration","Art and Award Winners","Economic","Healthcare","Intellectuals","Law and Judiciary","Religious","Science and Research","Social Leaders and Organizations","Sports"];
  String? selectedSoochi;
  List<String> soochis = ["AkhilaBharthiya","JillaSampark","PranthyaSampark"];
  String? selectedInteractionLevel;
  List<String> interactionLevels = ["Sahabhag","Sahavas","Samarthan","Sampark"];


  late bool loading = true;
  late String GV_id = '';
  List<dynamic> hashtags = [];
  List<dynamic> selectedHashtags = [];
  Set<int> selectedHashtagsIDs = {};

  Future<void> fetchShreni() async {
    try {
      // Call the apiService.homePage() and store the result
      var result = await apiService.myTeam(0, 100);
      if (result.isEmpty) {
        setState(() {
          selectedKaryakarthaId = apiService.UserId;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alert'),
              content: Text('No karyakartha to assign \n defualting to self:${apiService.first_name}'),
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
      await getGanyavyakthi();
      if (selectedKaryakarthaId == apiService.UserId) {
        result.add({'id': apiService.UserId,'first_name': 'self(${apiService.first_name}','last_name': '${apiService.last_name}) : Originally Selected'});
      } else {
        result.add({'id': apiService.UserId,'first_name': 'self(${apiService.first_name}','last_name': '${apiService.last_name})'});
        result.add({'id': selectedKaryakarthaId,'first_name': 'Do Not Change','last_name': '',});
      }
      setState(() {
        //log('karyakartha\'s $result');
        karyakartha = result;
      });
    } catch (e) {
      log("Error fetching karyakarthas: $e");
    }
  }

  Future<bool> getGanyavyakthi() async{
    try {
      setState(() {
        loading=true;
      });
      // Call the apiService.homePage() and store the result
      result = await apiService.getGanyavyakthi(GV_id);
      setState(() {
        // Update the influencers list with the fetched data
        //meetings = result;
        //log('get GV: ${result[0]}');
        profileImage = result[0]['profile_image']??'';
        fnameController.text = result[0]['fname'];
        lnameController.text = result[0]['lname'];
        designationController.text = result[0]['designation']??'';
        descriptionController.text = result[0]['description']??'';
        impactOnSocietyController.text = result[0]['impact_on_society']??'';
        organizationController.text = result[0]['organization']??'';
        //log(organisationController.text);
        if (result[0]['soochi'] == 'AkhilaBharthiya'){
          soochiController.text = 'AB';
        }else if(result[0]['soochi'] == 'PranthyaSampark'){
          soochiController.text = 'PS';
        }else if(result[0]['soochi'] == 'JillaSampark'){
          soochiController.text = 'JS';
        }
        shreniController.text = result[0]['shreni']??'';
        phoneController.text = result[0]['phone_number']??'';
        address1Controller.text = result[0]['address']??'';
        state1Controller.text = result[0]['state']??'';
        district1Controller.text = result[0]['district']??'';
        emailController.text = result[0]['email']??'';
        selectedKaryakarthaId = result[0]['assigned_karyakarta'];
        //log(selectedKaryakarthaId);
        if (interactionLevels.contains(result[0]['interaction_level'])) {
          selectedInteractionLevel = result[0]['interaction_level'];
        }
        if (soochis.contains(result[0]['soochi'])) {
          selectedSoochi = result[0]['soochi'];
        }
        if (shrenis.contains(result[0]['shreni'])) {
          selectedShreni = result[0]['shreni'];
        }

        //log(result[0]['email']);
        //log('object');
        //interactionLevelController.text = result[0]['interaction_level']??'';
        //_image = result[0]['profile_image']??'';
        //log('Image: ${result[0]['profile_image']??''}');
        setState(() {
          loading = false;
        });

      });
      //log('${result[0]['hashtags']}');
      for (var id in result[0]['hashtags']) {
        toggleHashtagSelection(id);
      }
      return true;
    } catch (e) {
      // Handle any errors here
      log("Error fetching influencers: $e");
    }
    return false;
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

  @override
  void initState() {
    super.initState();
    _myController.addListener(() {
      setState(() {loading=true;}); // Rebuild to show/hide label dynamically
    });
    GV_id = widget.id;
    //log(GV_id[0][0]);
    if(apiService.lvl>2){
      //getGanyavyakthi called inside fetchShreni
      fetchShreni();
    }else{
      getGanyavyakthi();
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
    loading = false;
    setState(() {loading=false;});
  }

  void updateInfluencer() {

    setState(() {loading=true;});

    List<dynamic> updateData = [
      phoneController.text,
      fnameController.text,
      lnameController.text,
      emailController.text,
      designationController.text,
      descriptionController.text,
      selectedHashtags,
      organizationController.text,
      impactOnSocietyController.text,
      selectedInteractionLevel,
      address1Controller.text,
      city1Controller.text,
      district1Controller.text,
      state1Controller.text,
      _image, // Only send if changed
      selectedKaryakarthaId,
      selectedShreni,
      selectedSoochi,
    ];

    apiService.updateGanyaVyakthi(updateData, GV_id).then((success) {
      String message = success ? "Update successful!" : "Update failed!";
      loading = success ? true : false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),backgroundColor: success ? Colors.green : Colors.red,));
      if (success){
        Navigator.pop(context,true);
      }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromRGBO(5, 50, 70, 1.0)), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                const Text(
                  "Update Details:",
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
                      buildProfileImage(context),
                      // add or edit image Button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Color.fromRGBO(5, 50, 70, 1.0), // Background color of the plus icon
                          child: IconButton(
                            icon: Icon((_image != null || (profileImage.isNotEmpty))? Icons.edit: Icons.add,color: Colors.white,),
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
                //f and l name
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
                _buildTextField(hint: "E-mail Address", controller: emailController),
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
                            "+ Add Hashtag",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(hint: "Address", controller: address1Controller),
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
                /*Row(
              children: [
                Expanded(
                  child: _buildTextField(hint: "City", controller: city1Controller),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(hint: "District", controller: district1Controller),
                ),
              ],
            ),*/
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
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 12), // space for label
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.grey.shade400,
                                  width: 1.0,
                                ),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedKaryakarthaId,
                                underline: SizedBox(), // Removes the default underline
                                hint: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    karyakartha.isNotEmpty
                                        ? 'Assign Karyakartha'
                                        : 'Loading Karyakartha\'s..',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ),
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
                              ),
                            ),
                            if (selectedKaryakarthaId != null) // Floating label only when value is selected
                              Positioned(
                                left: 12,
                                top: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  color: Colors.grey[200],
                                  child: Text(
                                    'Assigned Karyakartha',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                //update Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
                      updateInfluencer();

                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 10, top: 10), // Adjust padding
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,  // Center the row content
                        children: [
                          Text(
                            (apiService.lvl < 2) ? 'Save Changes' : 'Save',
                            style: const TextStyle(
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
          if(loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 20, // Customize the radius of the activity indicator
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
      )
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

  Widget buildProfileImage(BuildContext context) {
    final double avatarRadius = MediaQuery.of(context).size.width * 0.20;
    final double iconSize = MediaQuery.of(context).size.width * 0.34;

    if (_image != null) {
      //Show picked file image
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 1.0),
        ),
        child: CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.grey[200],
          backgroundImage: FileImage(_image!),
        ),
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width * 0.40,
        height: MediaQuery.of(context).size.width * 0.40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: (profileImage.isNotEmpty
                  ? const Color.fromRGBO(5, 50, 70, 1.0)
                  : Colors.grey)
                  .withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: profileImage.isNotEmpty ? 7 : 3,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(90),
          child: profileImage.isNotEmpty
              ? Image.network(
            profileImage,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Icon(Icons.error, color: Colors.grey,size: MediaQuery.of(context).size.width * 0.10),
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
      );
    }
  }


}
