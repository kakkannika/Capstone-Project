import 'package:flutter/material.dart';
import 'sucess_reset_screen.dart';
import 'otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool isEmailSelected = true; // Toggle between email and phone input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF085794), // Dark Blue
              Color(0xFF17649F), // Medium Blue
              Color(0xFF206CA6), // Light Blue
              Color(0xFF74B5E3), // Very light Blue
              Color(0xFFFFFFFF), // White
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'lib/assets/images/logo.png',
                height: 150,
              ),
              const SizedBox(height: 30),

              const Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Reset using phone or email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),

              // Toggle between email and phone input
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text(
                      "Email",
                      style: TextStyle(color: Colors.black),
                    ),
                    selected: isEmailSelected,
                    onSelected: (selected) {
                      setState(() {
                        isEmailSelected = selected;
                      });
                    },
                    selectedColor: Colors.blueAccent,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  ChoiceChip(
                    label: const Text(
                      "Phone",
                      style: TextStyle(color: Colors.black),
                    ),
                    selected: !isEmailSelected,
                    onSelected: (selected) {
                      setState(() {
                        isEmailSelected = !selected;
                      });
                    },
                    selectedColor: Colors.blueAccent,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Email or Phone Fields based on the toggle selection
              if (isEmailSelected)
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color(0x80FFFFFF),
                  ),
                )
              else
                Row(
                  children: [
                    DropdownButton<String>(
                      value: '+855',
                      onChanged: (String? newValue) {},
                      items: <String>['+855', '+44', '+91', '+33']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color(0x80FFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Handle cancel logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      if (isEmailSelected) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SuccessResetEmailScreen()));
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EnterOTPScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
