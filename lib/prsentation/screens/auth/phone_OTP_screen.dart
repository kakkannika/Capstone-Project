import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:tourism_app/prsentation/screens/home/home_screen.dart';
import 'package:tourism_app/services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;

  const OTPScreen({super.key, required this.verificationId});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the OTP sent to your phone",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ✅ OTP Input Field
            Pinput(
              length: 6,
              controller: _pinController,
              pinAnimationType: PinAnimationType.fade,
              keyboardType: TextInputType.number,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 50,
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 30),
            _verifyOTPButton(context),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive the OTP? ",
                  style: TextStyle(color: Colors.black54),
                ),
                TextButton(
                  onPressed: () {
                    // Implement resend functionality here
                  },
                  child: const Text(
                    "Resend",
                    style: TextStyle(color: Color(0xFF2F80ED)),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifyOTPButton(BuildContext context) {
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
        onPressed: _isLoading ? null : () async {
          setState(() => _isLoading = true);

          bool isVerified = await AuthService().verifyOTP(widget.verificationId, _pinController.text);

          if (isVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid OTP, please try again")),
            );
          }

          setState(() => _isLoading = false);
        },
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Verify OTP', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
