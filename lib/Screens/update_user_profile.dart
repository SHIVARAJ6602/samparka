import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final phoneController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final designationController = TextEditingController();

  String? selectedGroupId;
  String? selectedKaryakarthaId;
  String? selectedShreni;

  String? selectedState;
  String? selectedDistrict;
  String? selectedCity;

  List<dynamic> groups = [];
  List<dynamic> members = [];
  List<dynamic> supervisor = [];
  List<dynamic> result = [];

  List<String> shrenis = [
    "Administration", "Art and Award Winners", "Economic", "Healthcare",
    "Intellectuals", "Law and Judiciary", "Religious", "Science and Research",
    "Social Leaders and Organizations", "Sports"
  ];
  List<String> states = ['Karnataka South', 'Maharashtra', 'Tamil Nadu'];
  List<String> districts = [];
  List<String> cities = [];

  bool isLoading = false;
  late String KR_id;
  String profileImage = '';
  String profileImageOrg = '';
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
    } catch (_) {
      _showSnackBar("Failed to load groups.");
    }
  }

  Future<void> fetchMembers() async {
    try {
      result = await apiService.myTeam(0, 100);
      if (result.isEmpty) {
        selectedKaryakarthaId = apiService.UserId;
        _showAlert("No ShreniPramukh to assign. Defaulting to self: ${apiService.first_name}");
      }
      result.add({
        'id': apiService.UserId,
        'first_name': 'self(${apiService.first_name})',
        'last_name': ''
      });
      setState(() {
        members = result;
      });
    } catch (_) {
      _showSnackBar("Error fetching ShreniPramukh.");
    }
  }

  Future<void> fetchSupervisor() async {
    try {
      result = await apiService.mySupervisor();
      setState(() {
        supervisor = result;
      });
    } catch (_) {
      _showSnackBar("Failed to load Supervisor.");
    }
  }

  Future<void> getKaryakartha() async {
    try {
      result = await apiService.getKaryakartha(KR_id);
      final data = result[0];

      setState(() {
        firstNameController.text = data['first_name'] ?? '';
        lastNameController.text = data['last_name'] ?? '';
        phoneController.text = data['phone_number'] ?? '';
        emailController.text = data['email'] ?? '';
        designationController.text = data['designation'] ?? '';
        profileImage = result[0]['profile_image']??'';
        profileImageOrg = result[0]['profile_image']??'';
        print("porfile image : $profileImage");
        selectedState = states.contains(data['state']) ? data['state'] : null;
        districts = selectedState != null ? stateDistricts[selectedState!] ?? [] : [];

        selectedDistrict = districts.contains(data['district']) ? data['district'] : null;
        cities = selectedDistrict != null ? districtCities[selectedDistrict!] ?? [] : [];

        selectedCity = cities.contains(data['city']) ? data['city'] : null;

        if (shrenis.contains(data['shreni'])) {
          selectedShreni = data['shreni'];
        }
      });
    } catch (_) {
      _showSnackBar("Failed to fetch user data.");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void updateUser() async {
    if (!_validateInputs()) return;

    setState(() => isLoading = true);

    final updateData = [
      phoneController.text.trim(),//0
      firstNameController.text.trim(),//1
      lastNameController.text.trim(),//2
      emailController.text.trim(),//3
      designationController.text.trim(),//4
      null, // password //5
      selectedGroupId,//6
      selectedKaryakarthaId,//7
      _image,//8
      selectedCity,//9
      selectedDistrict,//10
      selectedState,//11
      selectedShreni,//12
    ];

    try {
      apiService.updateUser(updateData, widget.id).then((success) {
        String message = success ? "Update successful!" : "Update failed!";
        isLoading = success ? true : false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),backgroundColor: success ? Colors.green : Colors.red,));
        if (success){
          Navigator.pop(context,true);
        }
      });
      //await apiService.updateUser(updateData, widget.id);
      //_showSnackBar("User updated successfully!");
    } catch (e) {
      _showSnackBar("Failed to update user.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _validateInputs() {
    if ([phoneController.text, firstNameController.text, lastNameController.text, designationController.text].any((e) => e.isEmpty)) {
      _showSnackBar("Please fill all required fields.");
      return false;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phoneController.text)) {
      _showSnackBar("Enter a valid 10-digit phone number.");
      return false;
    }

    if (emailController.text.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(emailController.text)) {
      _showSnackBar("Enter a valid email address.");
      return false;
    }

    if (selectedState == null || selectedDistrict == null) {
      _showSnackBar("Select State and District.");
      return false;
    }

    if (selectedGroupId == '1' && selectedKaryakarthaId == null) {
      _showSnackBar("Select ShreniPramukh.");
      return false;
    }

    if ((selectedGroupId == '1' || selectedGroupId == '2') && selectedShreni == null) {
      _showSnackBar("Select Shreni.");
      return false;
    }

    return true;
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Alert"),
        content: Text(message),
        actions: [TextButton(child: Text("OK"), onPressed: () => Navigator.of(context).pop())],
      ),
    );
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
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
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
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: SizedBox(),
        hint: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(hint)),
        value: value,
        items: items,
        onChanged: onChanged,
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
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 0,
          title: Text('Edit Profile')
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                //profile Image
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
                            icon: Icon((_image != null || (apiService.profileImage.isNotEmpty))? Icons.edit: Icons.add,color: Colors.white,),
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
                SizedBox(height: 16),
                _buildTextField(hint: "Phone Number", controller: phoneController),
                SizedBox(height: 16),
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
                if(widget.id != apiService.UserId)
                SizedBox(height: 20),
                if(widget.id != apiService.UserId)
                buildDropdownContainer(
                  hint: 'Select Group',
                  value: selectedGroupId,
                  items: groups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group['id'].toString(),
                      child: Text(group['name']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedGroupId = val);
                    if (val == '1') fetchMembers();
                  },
                ),

                if (selectedGroupId == '1') ...[
                  SizedBox(height: 16),
                  buildDropdownContainer(
                    hint: 'Select ShreniPramukh',
                    value: selectedKaryakarthaId,
                    items: members.map((m) {
                      return DropdownMenuItem<String>(
                        value: m['id'].toString(),
                        child: Text('${m['first_name']} ${m['last_name']}'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedKaryakarthaId = val),
                  ),
                ],

                if (selectedGroupId == '1' || selectedGroupId == '2') ...[
                  SizedBox(height: 16),
                  buildDropdownContainer(
                    hint: 'Select Shreni',
                    value: selectedShreni,
                    items: shrenis.map((s) {
                      return DropdownMenuItem<String>(
                        value: s,
                        child: Text(s),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => selectedShreni = val),
                  ),
                ],

                SizedBox(height: 16),
                buildDropdownContainer(
                  hint: 'Select State',
                  value: selectedState,
                  items: states.map((s) => DropdownMenuItem(value: s, child: Text('   $s'))).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedState = val;
                      selectedDistrict = null;
                      selectedCity = null;
                      districts = stateDistricts[val] ?? [];
                    });
                  },
                ),

                if (selectedState != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: buildDropdownContainer(
                      hint: 'Select District',
                      value: selectedDistrict,
                      items: districts.map((d) => DropdownMenuItem(value: d, child: Text('   $d'))).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedDistrict = val;
                          selectedCity = null;
                          cities = districtCities[val] ?? [];
                        });
                      },
                    ),
                  ),
                //Select City
                /*if (selectedDistrict != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: buildDropdownContainer(
                      hint: 'Select City',
                      value: selectedCity,
                      items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => selectedCity = val),
                    ),
                  ),
                 */
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
              color: (apiService.profileImage.isNotEmpty
                  ? const Color.fromRGBO(5, 50, 70, 1.0)
                  : Colors.grey)
                  .withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: apiService.profileImage.isNotEmpty ? 7 : 3,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(90),
          child: apiService.profileImage.isNotEmpty
              ? Image.network(
            apiService.profileImage,
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

  Widget _buildProfileImageSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.20,
            backgroundColor: Colors.grey[200],
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null ? Icon(Icons.person, color: Colors.white, size: 80) : null,
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
                    builder: (_) => Column(
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
                  onPressed: () => setState(() => _image = null),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
