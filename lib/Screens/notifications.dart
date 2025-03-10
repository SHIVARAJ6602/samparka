import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
              children: [
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
                      padding: const EdgeInsets.only(left: 0,right: 0, bottom: 10,top: 10), // Remove padding to fill the entire container
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                    ),
                    child: Row(

                      children: [
                        SizedBox(width: 16),
                        Text(
                          'New Resources',
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 16,),
                        Container(
                          width: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color.fromRGBO(255, 0, 0, 1.0),
                                Color.fromRGBO(255, 0, 0, 1.0)
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '2',
                              style: TextStyle(

                                fontSize: 23,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            /*
            Column(
              children: List.generate(
                (GanyaVyakthis.length < 4)?
                    (index) {
                  final influencer = GanyaVyakthis[index]; // Access the member data
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 10,bottom: 10),
                    child: InfluencerCard(
                      id: influencer[0]['id']!,
                      name: influencer[0]['fname']??'',
                      designation: influencer[0]['designation']!,
                      description: influencer[0]['description']??'',
                      hashtags: influencer[0]['hashtags']??'',
                      soochi: influencer[0]['soochi']??'',
                      itrLvl: influencer[0]['interaction_level']??'',
                      profileImage: influencer[0]['profile_image'] != null && influencer[0]['profile_image']!.isNotEmpty
                          ? apiService.baseUrl.substring(0,40)+influencer[0]['profile_image']!
                          : '',
                    ),
                  );
                },
              ),
            ),*/
          ],
        ),
      )
    );
  }
}