import 'package:flutter/material.dart';
import 'package:tourism_app/prsentation/screens/profile/settings_screen.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 50,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }
  
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text(
        'Profile',
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
    );
  }
  
//to build the body of the ProfileScreen with a profile image, profile information, a tab bar, and a tab bar view
  Widget _buildBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileImage(),
              const SizedBox(height: 16),
              _buildProfileInfo(),
              const SizedBox(height: 20),
            ],
          ),
        ),
        _buildTabBar(),
        _buildTabBarView(),
      ],
    );
  }

//to build the profile image for the ProfileScreen
  Widget _buildProfileImage() {
    return const CircleAvatar(
      radius: 50,
      backgroundImage: AssetImage('lib/assets/images/profile.png'),
    );
  }

//to build the profile information for the ProfileScreen
  Widget _buildProfileInfo() {
    return const Column(
      children: [
        Text(
          'Kannika KAK',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          '@kannika',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

//to build the tab bar for the ProfileScreen with two tabs: Trips and History
  Widget _buildTabBar() {
    return const TabBar(
      labelColor: Color(0xFF386FA4),
      unselectedLabelColor: Colors.grey,
      indicatorColor: Color(0xFF386FA4),
      tabs: [
        Tab(text: 'Trips'),
        Tab(text: 'History'),
      ],
    );
  }

//to build the tab bar view for the ProfileScreen with two tabs: Trips and History
  Widget _buildTabBarView() {
    return Expanded(
      child: TabBarView(
        children: [
          _buildTripsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

//to build the Trips tab for the ProfileScreen with a list of trips
  Widget _buildTripsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripItem('Trip to Siem Reap', '1 place', 'Planning'),
        _buildTripItem('Trip to Bali', '2 places', 'Upcoming'),
      ],
    );
  }
//to build the History tab for the ProfileScreen with a list of trips
  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripItem('Kampot Trip', '3 places', 'Completed'),
        _buildTripItem('Koh Rong Tour', '2 places', 'Completed'),
      ],
    );
  }
//to build a trip item for the ProfileScreen
  Widget _buildTripItem(String title, String places, String status) {
    final isCompleted = status == 'Completed';
    final statusColor = isCompleted ? Colors.green : const Color(0xFF386FA4);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(title),
        subtitle: Text(places),
        trailing: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: _goToTripDetails,
      ),
    );
  }
//to show the option to choose such as ,setting edit profile or view profile reset password,logout
  void _showMoreOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('More Options'),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                _goToSettings(context);
              },
            ),
            _buildOptionTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                Navigator.pop(context);
                _editProfile(context);
              },
            ),
            _buildOptionTile(
              icon: Icons.lock_outline,
              title: 'Reset Password',
              onTap: () {
                Navigator.pop(context);
                _resetPassword(context);
              },
            ),
            _buildOptionTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => _showLogoutConfirmation(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  void _goToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
//to build the option tile 
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF386FA4)),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
//to show logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              _logout(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _goToTripDetails() => debugPrint('Navigate to Trip Details');
  void _editProfile(BuildContext context) => Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
  void _logout(BuildContext context) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  void _resetPassword(BuildContext context) => debugPrint('Reset Password');
}
