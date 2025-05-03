import 'package:flutter/material.dart';

class ApprovalCard extends StatelessWidget {
  final String name;
  final String designation;
  final String description;
  final String hashtags;
  final String imageUrl;
  final String soochi;
  final String itrLvl;
  final String shreni;
  final VoidCallback onPress; // Callback to handle button press

  const ApprovalCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags,
    required this.imageUrl,
    required this.onPress,
    required this.soochi,
    required this.itrLvl,
    required this.shreni,
  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize + 4; //20
    double smallFontSize = normFontSize - 2; //14

    return Container(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Row: Profile Picture and Influencer Details
                Row(
                  children: [
                    // Profile Picture (placeholder)
                    Container(
                      width: (MediaQuery.of(context).size.width * 0.80) / 5,  // 90% of screen width divided by 3 images
                      height: (MediaQuery.of(context).size.width * 0.80) / 5,  // Fixed height for each image
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey.shade400),
                        color: Colors.grey[200],
                        boxShadow: [
                          if(imageUrl.isNotEmpty)
                            BoxShadow(
                              color: Color.fromRGBO(5, 50, 70, 1.0).withOpacity(0.5), // Grey shadow color with opacity
                              spreadRadius: 1, // Spread radius of the shadow
                              blurRadius: 7, // Blur radius of the shadow
                              offset: Offset(0, 4), // Shadow position (x, y)
                            ),
                          if(imageUrl.isEmpty)
                            BoxShadow(
                              color: Color.fromRGBO(59, 171, 144, 1.0).withOpacity(0.5), // Grey shadow color with opacity
                              spreadRadius: 1, // Spread radius of the shadow
                              blurRadius: 7, // Blur radius of the shadow
                              offset: Offset(0, 2), // Shadow position (x, y)
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: (imageUrl.isNotEmpty)
                            ? Image.network(
                          imageUrl,  // Ensure the URL is encoded
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;  // Image loaded successfully
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white,  // Placeholder color for invalid image URLs
                              child: Center(
                                child: Icon(Icons.error, color: Colors.grey),  // Display error icon
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
                    ),
                    SizedBox(width: 16),
                    // Influencer Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double fontSize = largeFontSize + 4; // Default font size
                              double availableWidth = name.length*largeFontSize;
                              //print('$fontSize $availableWidth ${MediaQuery.of(context).size.width * 0.38*2}');

                              if (availableWidth > MediaQuery.of(context).size.width * 0.38*2) {
                                fontSize = normFontSize; // Adjust this to your needs
                              }
                              return Text(
                                name,
                                style: TextStyle(
                                  fontSize: fontSize, // Adjusted font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis, // Truncate with ellipsis if the text overflows
                                softWrap: false, // Prevent wrapping
                              );
                            },
                          ),
                          Row(
                            children: [
                              Text(
                                designation,
                                style: TextStyle(
                                  fontSize: smallFontSize,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 5),
                              SizedBox(
                                  width: 2,
                                  child: Container(
                                    width: 1,
                                    height: smallFontSize,
                                    color: Colors.white,
                                  )),
                              SizedBox(width: 5),
                              Text(
                                shreni,
                                style: TextStyle(
                                  fontSize: smallFontSize,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: smallFontSize - 2,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1),
                          Text(
                            hashtags,
                            style: TextStyle(
                              fontSize: smallFontSize - 2,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Second Row: Approval Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Align button to the end
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.65,
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
                        onPressed: onPress, // Trigger the parent function
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Approve and Assign',
                                style: TextStyle(
                                  fontSize: largeFontSize,
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
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 18,  // Diameter of the circle
                height: 18,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(59, 171, 144, 1.0),  // Blue background color
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromRGBO(198, 198, 198, 1.0), // Border color
                    width: 0.8, // Border width
                  ),
                ),
                child: Center(
                  child: Text(
                    soochi,  // The letter inside the circle
                    style: TextStyle(
                      fontSize: smallFontSize - 3,  // Font size for "L"
                      color: Colors.white,  // White color for the letter
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 15,
              child: Container(
                width: 18,  // Diameter of the circle
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.blue,  // Blue background color
                  shape: BoxShape.circle,  // Make it a circle
                  border: Border.all(
                    color: const Color.fromRGBO(198, 198, 198, 1.0), // Border color
                    width: 0.8, // Border width
                  ),
                ),
                child: Center(
                  child: Text(
                    itrLvl,  // The letter inside the circle
                    style: TextStyle(
                      fontSize: smallFontSize-3,  // Font size for "L"
                      color: Colors.white,  // White color for the letter
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }
}
