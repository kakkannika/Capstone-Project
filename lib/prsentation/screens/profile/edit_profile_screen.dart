import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Kannika KAK');
  final TextEditingController _phoneController = TextEditingController(text: '+855 1234569');
  final TextEditingController _emailController = TextEditingController(text: 'kannika@example.com');
  final TextEditingController _passwordController = TextEditingController(text: 'password123');
  
  bool _obscurePassword = true;

  Future<void> _saveProfile() async {
    bool confirm = await _showConfirmationDialog();
    if (confirm) {
      Navigator.pop(context); // Close EditProfileScreen
    }
  }
  
  //to show the confirmation dialog when the user tries to save the changes
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Save'),
          content: const Text('Are you sure you want to save the changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    ) ?? false;
  }

  //to show the dialog to change the profile picture when the user taps on the profile picture in the EditProfileScreen such that the user can choose to take a photo or choose from the gallery
  void _changeProfilePicture() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Change Profile Picture', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Take a photo'),
                onTap: () {
                  // TODO: Implement camera functionality
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.green),
                title: const Text('Choose from gallery'),
                onTap: () {
                  // TODO: Implement gallery selection
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
 
 //to build the app bar for the EditProfileScreen with a back button and a title
  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontSize: 20)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
 //to build the body of the EditProfileScreen with a profile image, text fields for the user to input their name, phone number, email, and password, and a save button to save the changes 
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildProfileImage(),
          const SizedBox(height: 50),
          _buildTextField('Name', _nameController, Icons.person),
          _buildTextField('Phone Number', _phoneController, Icons.phone, TextInputType.phone),
          _buildTextField('Your Email', _emailController, Icons.email, TextInputType.emailAddress),
          _buildPasswordField(),
          const SizedBox(height: 80),
          SizedBox(
            width: 200,
            child: OutlinedButton(
              onPressed: _saveProfile,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 16, color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }
 //to build the profile image with a circle avatar and an edit icon on the bottom right corner to allow the user to change the profile picture
  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('lib/assets/images/profile.png'),
        ),
        GestureDetector(
          onTap: _changeProfilePicture,
          child: const CircleAvatar(
            radius: 15,
            backgroundColor: Colors.blue,
            child: Icon(Icons.edit, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  //to build the text field with a label, icon, and border
  Widget _buildTextField(String label, TextEditingController controller, IconData icon, [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),//to set the border color to grey when the text field is default
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),//to set the border color to grey when the text field is not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),//to set the border color to blue with a width of 2 when the text field is focused
          ),
        ),
      ),
    );
  }

//to build the password field with a label, icon, border, and a visibility icon to show or hide the password
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock),
           // Match the border styling with other text fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
}
