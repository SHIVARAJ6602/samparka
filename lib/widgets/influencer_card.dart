import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../Screens/influencer_profile.dart';

class InfluencerCard extends StatelessWidget {
  final String id;
  final String name;
  final String designation;
  final String description;
  final String hashtags;
  final String soochi;
  final String shreni;
  final String itrLvl;
  final String profileImage;

  const InfluencerCard({
    super.key,
    required this.name,
    required this.designation,
    required this.description,
    required this.hashtags,
    required this.profileImage,
    required this.id,
    required this.soochi,
    required this.itrLvl, required this.shreni,
  });

  @override
  Widget build(BuildContext context) {
    double normFontSize = MediaQuery.of(context).size.width * 0.041; //16
    double largeFontSize = normFontSize+4; //20
    double smallFontSize = normFontSize-2; //14
    return Stack(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(0), // Container padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InfluencerProfilePage(id)),
                );
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                )),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 0,right: 0,bottom: 8,top: 8), // Add padding to the content
                child: Row(
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
                          if(profileImage.isNotEmpty)
                            BoxShadow(
                              color: Color.fromRGBO(5, 50, 70, 1.0).withAlpha(180), // Grey shadow color with opacity
                              spreadRadius: 1, // Spread radius of the shadow
                              blurRadius: 7, // Blur radius of the shadow
                              offset: Offset(0, 4), // Shadow position (x, y)
                            ),
                          if(profileImage.isEmpty)
                            BoxShadow(
                              color: Colors.grey.withAlpha(180), // Grey shadow color with opacity
                              spreadRadius: 1, // Spread radius of the shadow
                              blurRadius: 3, // Blur radius of the shadow
                              offset: Offset(0, 4), // Shadow position (x, y)
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: (profileImage.isNotEmpty)
                            ? Image.network(
                          profileImage,  // Ensure the URL is encoded
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
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: largeFontSize+6,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(5, 50, 70, 1.0),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AutoSizeText(
                                  designation,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: smallFontSize,
                                    color: Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                  minFontSize: smallFontSize.floorToDouble(),
                                  stepGranularity: 1.0,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 5),
                              SizedBox(
                                  width: 1.25,
                                  child: Container(
                                    width: 0.5,
                                    height: smallFontSize,
                                    color: Color.fromRGBO(5, 50, 70, 1.0),
                                  )),
                              SizedBox(width: 5),
                              Expanded(
                                child: AutoSizeText(
                                  shreni,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: smallFontSize,
                                    color: Color.fromRGBO(5, 50, 70, 1.0),
                                  ),
                                  minFontSize: smallFontSize.floorToDouble(),
                                  stepGranularity: 1.0,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            description, // Dynamic designation
                            style: TextStyle(
                              fontSize: smallFontSize,
                              color: Color.fromRGBO(5, 50, 70, 1.0),
                            ),
                          ),
                          Text(
                            hashtags, // Dynamic designation
                            style: TextStyle(
                              fontSize: smallFontSize,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(height: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 15,
          child: Container(
            width: 25,  // Diameter of the circle
            height: 25,
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
                  fontSize: smallFontSize - 1,  // Font size for "L"
                  color: Colors.white,  // White color for the letter
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 35,
          child: Container(
            width: 25,  // Diameter of the circle
            height: 25,
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
                  fontSize: smallFontSize-1,  // Font size for "L"
                  color: Colors.white,  // White color for the letter
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}