import 'package:flutter/material.dart';
import 'package:samparka/Screens/l1home.dart'; // Assuming InfluencersPage is the next screen
import 'package:samparka/Service/api_service.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final apiService = ApiService();
  bool _otpSent = false;  // Track whether OTP has been sent
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
                    focusNode: _phoneFocusNode,  // Attach the focus node for phone field
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
                      right: 10,
                      top: 10,
                      bottom: 10,
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
              TextField(
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
              ),
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
                    onPressed: () async {
                      await apiService.getOTP(_phoneNumber,_mail);
                      setState(() {
                        _otpSent = true;  // Change state to show OTP field and login button
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent, // Make background transparent
                      shadowColor: Colors.transparent, // Remove shadow
                    ),
                    child: const Text(
                      'Get OTP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                    // Log the phone number and OTP entered
                    print("Phone Number: $_phoneNumber");
                    print("OTP Entered: $_otpEntered");
                    // Handle login logic or navigate to home page
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
                    onPressed: () {
                      apiService.login(_phoneNumber, _otpEntered);
                      // Log the phone number and OTP entered
                      print("Phone Number: $_phoneNumber");
                      print("OTP Entered: $_otpEntered");

                      // Handle login logic or navigate to home page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfluencersPage(),
                        ),
                      );
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
                    onPressed: () {
                      // Handle OTP resend logic here
                      // Show temporary popup
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OTP has been resent!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
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
