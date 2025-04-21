import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samparka/Screens/home.dart'; // Assuming InfluencersPage is the next screen
import 'package:samparka/Service/FCM.dart';
import 'package:samparka/Service/api_service.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final apiService = ApiService();
  //PhoneEmail.initializeApp(clientId: '14349191896196900482');
  bool _otpSent = false;  // Track whether OTP has been sent
  bool _isLoading = false;  // Add a loading state to manage button disable/enable
  bool _noOTP = false;  // Add a loading state to manage button disable/enable
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  // Variables to store the phone number and OTP entered by the user
  String _phoneNumber = '';
  String _otpEntered = '';
  /************************************************************/
  String _mail = '';
  final TextEditingController _mailController = TextEditingController();
  final FocusNode _mailFocusNode = FocusNode();

  // Focus nodes for phone number and OTP fields to control focus behavior
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    /******************************/
    _mailFocusNode.dispose();

    super.dispose();
  }

  void show_Dialog(BuildContext context, String message) {
    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing it manually
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Samparka:'),
          content: Text(message, style: TextStyle(color: Colors.red,fontSize: 18,),),
        );
      },
    );
    // Dismiss the dialog after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Image.asset(
                'assets/logo/logo.png',
                height: 150,
              ),
              const SizedBox(height: 24),
              // Phone Number Input Field (Uneditable after OTP is sent)
              Stack(
                children: [
                  TextField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: 'Enter Phone Number',
                      filled: true,
                      fillColor: Colors.white,
                      suffixStyle: const TextStyle(color: Color.fromRGBO(150, 150, 150, 1)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(150, 150, 150, 1),
                          width: 0.1,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: _phoneNumber.length < 10 ? Colors.red : Colors.green,fontSize: 18),
                    enabled: !_otpSent,  // Disable phone input after OTP is sent
                    onChanged: (value) {
                      setState(() {
                        _phoneNumber = value;  // Update phone number variable
                      });
                    },
                    textInputAction: TextInputAction.done,  // "Next" button on keyboard moves to OTP field
                    onSubmitted: (_) {
                      // When "Next" is pressed on the phone number field, move focus to OTP field
                      FocusScope.of(context).requestFocus(_otpFocusNode);
                    },
                  ),
                  if (_otpSent)
                    Positioned(
                      right: 5,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Color.fromRGBO(10, 205, 165, 1.0)),
                        onPressed: () {
                          setState(() {
                            _otpSent = false;  // Reset OTP sent flag to allow phone number editing
                          });
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              /********** TEMP (Mail OTP) *************/
              /*TextField(
                controller: _mailController,
                focusNode: _mailFocusNode,  // Attach the focus node for phone field
                decoration: InputDecoration(
                  hintText: '**Enter Email**',
                  filled: true,
                  fillColor: Colors.white,
                  suffixStyle: const TextStyle(color: Color.fromRGBO(150, 150, 150, 1)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(150, 150, 150, 1),
                      width: 0.1,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _mail = value;  // Update phone number variable
                  });
                },
                textInputAction: TextInputAction.done,  // "Next" button on keyboard moves to OTP field
                onSubmitted: (_) {
                  // When "Next" is pressed on the phone number field, move focus to OTP field
                  FocusScope.of(context).requestFocus(_otpFocusNode);
                },
              ),*/
              /*************************/
              const SizedBox(height: 16),

              // Get OTP Button with Gradient
              if (!_otpSent) ...[
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color.fromRGBO(2, 40, 60, 1), Color.fromRGBO(10, 205, 165, 1.0)],
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null  // Disable button if loading
                        : () async {
                      setState(() {
                        _isLoading = true;  // Set loading to true to disable the button
                      });

                      // Call the apiService to get the OTP
                      var response = await apiService.getOTP(_phoneNumber, '');
                      print('response: ${response}');
                      String message = '';
                      if (response == 200){
                        setState(() {
                          _otpSent = true;
                          apiService.saveData();
                          apiService.loadData();
                          show_Dialog(context, 'OTP sent successfully');

                          // Handle login logic or navigate to home page
                          //below code is not needed( used when otp was not available)
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InfluencersPage(),
                            ),
                          );*/
                        });
                      }else if(response == 400){
                        show_Dialog(context, 'failed to send otp');
                      }else if(response == 404){
                        show_Dialog(context, 'Number not registered');
                      }else if(response==500){
                        show_Dialog(context, 'Internal Server Error');
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent, // Make background transparent
                      shadowColor: Colors.transparent, // Remove shadow
                    ),
                    child: Text(
                      //'Login',
                      'Get OTP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isLoading ? Colors.green : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 5),
              // OTP Input Field (Visible once OTP is sent)
              if (_otpSent) ...[
                TextField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    hintText: 'Enter OTP',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _otpEntered = value;  // Update OTP entered variable
                    });
                  },
                  textInputAction: TextInputAction.done,  // "Done" button for final submission
                  focusNode: _otpFocusNode,  // Link to the OTP field focus
                  onSubmitted: (_) async {
                    await apiService.login(_phoneNumber, _otpEntered);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InfluencersPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Login Button with Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color.fromRGBO(2, 40, 60, 1), Color.fromRGBO(10, 205, 165, 1.0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      Response response = await apiService.login(_phoneNumber, _otpEntered);
                      String message = '';
                      print(response.statusCode);
                      if (response.statusCode == 200) {
                        setState(() {
                          apiService.saveData();
                          apiService.loadData();
                          message = response.data['message'] ?? 'Successful';
                        });
                        initFCM();
                        // Handle login logic or navigate to home page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InfluencersPage(),
                          ),
                        );
                      }
                      else {
                        message = response.data['message'] ?? 'Unauthorized access';
                      }

                      show_Dialog(context, message);

                      // Log the phone number and OTP entered
                      print("Phone Number: $_phoneNumber");
                      print("OTP Entered: $_otpEntered");

                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent, // Make background transparent
                      shadowColor: Colors.transparent, // Remove shadow
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Resend OTP Button centered
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null  // Disable button if loading
                        : () async {
                      setState(() {
                        _isLoading = true;  // Set loading to true to disable the button
                      });

                      // Call the apiService to get the OTP
                      var response = await apiService.getOTP(_phoneNumber, _mail);
                      print(response);

                      if (response == 200){
                        setState(() {
                          _otpSent = true;  // Change state to show OTP field and login button
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('OTP has been resent!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }else if(response == 400){
                        print(response);
                        show_Dialog(context, 'failed to send otp ${response}');
                      }else if(response == 404){
                        show_Dialog(context, 'Number not registered');
                      }else if(response==500){
                        show_Dialog(context, 'Internal Server Error');
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: Color.fromRGBO(2, 40, 60, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
