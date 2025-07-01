import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:samparka/Screens/home.dart';
import 'package:samparka/Service/FCM.dart';
import 'package:samparka/Service/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final apiService = ApiService();
  bool _otpSent = false;
  bool _isLoading = false;
  bool _noOTP = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();

  List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());


  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final FocusNode _mailFocusNode = FocusNode();

  String _phoneNumber = '';
  String _otpEntered = '';
  String _mail = '';

  Timer? _resendOTPTimer;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _resendOTPTimer?.cancel();
    _phoneFocusNode.dispose();
    _otpFocusNode.dispose();
    _mailFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }


  void _startResendOTPTimer() {
    setState(() {
      _resendCountdown = 30;
    });

    _resendOTPTimer?.cancel();
    _resendOTPTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendCountdown--;
        });
      }
    });
  }

  void show_Dialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Samparka says:',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
          content: Text(
            message,
            style: TextStyle(color: Colors.deepOrange, fontSize: 18,fontWeight: FontWeight.bold),
          ),
        );
      },
    );
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  void _handleOtpSubmit(String otp) async {
    if (otp.length == 6) {
      final response = await apiService.login(context, _phoneNumber, otp);
      if (response.statusCode == 200) {
        initFCM();
        Navigator.push(context, MaterialPageRoute(builder: (context) => const InfluencersPage()));
      } else {
        show_Dialog(context, 'Invalid OTP');
      }
    }
  }


  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
              }
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
              }
            },
            onSubmitted: (_) {
              if (index == 5) {
                String otp = _otpControllers.map((c) => c.text).join();
                _handleOtpSubmit(otp);
              }
            },
          ),
        );
      }),
    );
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
              Image.asset(
                'assets/logo/logo.png',
                height: 150,
              ),
              const SizedBox(height: 24),

              // Phone Number Input Field
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: _phoneNumber.length < 10 ? Colors.red : Colors.green,
                      fontSize: 18,
                    ),
                    enabled: !_otpSent,
                    onChanged: (value) {
                      setState(() {
                        _phoneNumber = value;
                      });
                    },
                    onSubmitted: (_) {
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
                            _otpSent = false;
                          });
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Get OTP Button
              if (!_otpSent)
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
                        ? null
                        : () async {
                      setState(() {
                        _isLoading = true;
                      });

                      var response = await apiService.getOTP(_phoneNumber, '');
                      if (response == 200) {
                        setState(() {
                          _otpSent = true;
                          apiService.saveData();
                          apiService.loadData();
                        });
                        _startResendOTPTimer();

                        show_Dialog(context, 'OTP sent successfully');
                      } else if (response == 400) {
                        show_Dialog(context, 'Failed to send OTP');
                      } else if (response == 404) {
                        show_Dialog(context, 'Number not registered');
                      } else if (response == 500) {
                        show_Dialog(context, 'Internal Server Error');
                      }

                      setState(() {
                        _isLoading = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      'Get OTP',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isLoading ? Colors.green : Colors.white,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 5),

              // OTP Input and Login
              // OTP Input and Login
              if (_otpSent) ...[
                const SizedBox(height: 6),

                // 6-digit OTP fields
                _buildOtpFields(),
                const SizedBox(height: 16),

                // Login Button
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
                      String otp = _otpControllers.map((c) => c.text).join();
                      if (otp.length < 6) {
                        show_Dialog(context, "Please enter 6-digit OTP");
                        return;
                      }

                      Response response = await apiService.login(context, _phoneNumber, otp);
                      String message = '';
                      if (response.statusCode == 200) {
                        apiService.saveData();
                        apiService.loadData();
                        message = response.data['message'] ?? 'Login Successful';
                        initFCM();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Login Successful', style: TextStyle(color: Colors.white)),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const InfluencersPage()));
                      } else {
                        message = response.data['message'] ?? 'Failed To Login';
                        show_Dialog(context, message);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
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

                const SizedBox(height: 12),

                // Resend OTP
                Center(
                  child: TextButton(
                    onPressed: (_isLoading || _resendCountdown > 0)
                        ? null
                        : () async {
                      setState(() {
                        _isLoading = true;
                      });

                      var response = await apiService.getOTP(_phoneNumber, _mail);
                      if (response == 200) {
                        setState(() {
                          _otpSent = true;
                        });
                        _startResendOTPTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('OTP has been resent!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (response == 400) {
                        show_Dialog(context, 'Failed to resend OTP');
                      } else if (response == 404) {
                        show_Dialog(context, 'Number not registered');
                      } else if (response == 500) {
                        show_Dialog(context, 'Something went wrong!');
                      }

                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend OTP in $_resendCountdown s'
                          : 'Resend OTP',
                      style: const TextStyle(
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
