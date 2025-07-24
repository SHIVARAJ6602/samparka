import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  //Resources
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Aligns everything at the top
                    children: [
                      Image.asset(
                        'assets/icon/resource_book-outline.png',
                        color: Color.fromRGBO(2, 40, 60, 1),
                        width: 70,
                        height: 70,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New',
                            style: TextStyle(
                              fontSize: 32,
                              color: Color.fromRGBO(2, 40, 60, 1),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Resources',
                            style: TextStyle(
                              fontSize: 40,
                              color: Color.fromRGBO(2, 40, 60, 1),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      // Add resource button aligned with 'New' text
                      Expanded(child: SizedBox()),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
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
                            // Add your onPressed logic here
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Center(
                            child: Text(
                              '+ Add Resource',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.041,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 25),
              Text(
                'Other Resources',
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