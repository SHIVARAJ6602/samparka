import 'package:flutter/material.dart';
import 'package:samparka/Screens/l1home.dart';

class AddInfluencerPage extends StatefulWidget {
  const AddInfluencerPage({super.key});

  @override
  _AddInfluencerPageState createState() => _AddInfluencerPageState();
}

class _AddInfluencerPageState extends State<AddInfluencerPage> {
  // This keeps track of the currently selected bottom navigation item.
  int _selectedIndex = 1;

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
  Widget build(BuildContext context) {
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
            //const SizedBox(height: 80),
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
            const SizedBox(height: 24),
            // Input Fields
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
            const SizedBox(height: 16),
            _buildTextField(hint: "Designation"),
            const SizedBox(height: 16),
            _buildTextField(hint: "E-mail Address"),
            const SizedBox(height: 16),
            _buildTextField(hint: "Phone Number"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(hint: "City"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(hint: "District"),
                ),
              ],
            ),
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
                          'Continue',
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
