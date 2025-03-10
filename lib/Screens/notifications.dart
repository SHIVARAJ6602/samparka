import 'package:flutter/material.dart';
import 'package:samparka/Screens/resources.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                //Resources
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResourcesPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.only(left: 6,right: 6, bottom: 6,top: 6), // Remove padding to fill the entire container
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Adjust the tap target size
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icon/resource_book-outline.png',
                          color: Colors.white,
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(width: 16),
                        Text(
                          'New Resources',
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),  // Pushes the rest of the content to the left, placing '2' at the right
                        Container(
                          width: 33,
                          height: 33,
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
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              'Other Notifications',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.041+15,
                fontWeight: FontWeight.w900,
                color: Color.fromRGBO(2, 40, 60, 1),
              ),
            ),
            SizedBox(height: 15),

          ],
        ),
      )
    );
  }
}