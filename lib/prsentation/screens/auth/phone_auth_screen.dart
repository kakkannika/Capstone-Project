import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/screens/auth/phone_OTP_screen.dart';
import 'package:tourism_app/services/auth_service.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/images/logo.png',
                  height: 100,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your phone number to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                _phoneNumberField(),
                const SizedBox(height: 20),
                _sendOTPButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneNumberField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: _phoneController,
        decoration: InputDecoration(
          hintText: 'Enter your phone number',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        keyboardType: TextInputType.phone,
      ),
    );
  }

  Widget _sendOTPButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F80ED),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          await AuthService().sendOTP(
            _phoneController.text,
            (verificationId) {
              setState(() {
                _isLoading = false;
              });
              //Navigate to OTP Screen after getting verificationId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OTPScreen(verificationId: verificationId),
                ),
              );
            },
          );
        },
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Send OTP', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
