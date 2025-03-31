// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/ui/providers/auth_provider.dart';
import 'package:tourism_app/ui/screens/chat_bot/chat_screen.dart';
import 'package:tourism_app/ui/screens/home/detail_home_pages.dart';
import 'package:tourism_app/ui/screens/profiles/profile_screen.dart';
import 'package:tourism_app/ui/widgets/navigationBar.dart';

enum Province {
  banteayMeanchey('Banteay Meanchey'),
  battambang('Battambang'),
  kampongCham('Kampong Cham'),
  kampongChhnang('Kampong Chhnang'),
  kampongSpeu('Kampong Speu'),
  kampot('Kampot'),
  kandal('Kandal'),
  kohKong('Koh Kong'),
  kratie('Kratie'),
  mondulkiri('Mondulkiri'),
  preahVihear('Preah Vihear'),
  preyVeng('Prey Veng'),
  pursat('Pursat'),
  ratanakiri('Ratanakiri'),
  siemReap('Siem Reap'),
  sihanoukville('Sihanoukville'),
  stungTreng('Stung Treng'),
  svayRieng('Svay Rieng'),
  takeo('Takeo'),
  tboungKhmum('Tboung Khmum'),
  phnomPenh('Phnom Penh'),
  kep('Kep'),
  oddarMeanchey('Oddar Meanchey'),
  pailin('Pailin');

  final String displayName;

  const Province(this.displayName);

  String get imagePath => 'assets/provinces/$name.jpg';
  // In your Province enum
  static Province fromDisplayName(String displayName) {
    return Province.values.firstWhere(
      (province) => province.displayName == displayName,
      orElse: () => Province.phnomPenh, // default fallback
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthServiceProvider>(context);
    final currentUser = authProvider.currentUser;
    final displayName = currentUser?.displayName ??
        (currentUser?.email.split('@')[0] ?? 'User');
    // Get all provinces as a list
    final List<Province> provinces = Province.values;
    return Scaffold(
      // header 
      appBar: AppBar(
        automaticallyImplyLeading: false,
        
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: currentUser?.photoUrl != null
                    ? NetworkImage(currentUser!.photoUrl!)
                    : const AssetImage('assets/images/avatar.jpg')
                        as ImageProvider,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              'Hello, $displayName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/place_images/Angkor.jpg',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Popular destination section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Provinces',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Popular destination carousel slider
              CarouselSlider(
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
                items: provinces.take(4).map((province) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailHomePages(
                                province: province.displayName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: AssetImage(province.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Text(
                                  province.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: Colors.black,
                                        offset: Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),

              // Explore Destination section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Explore Destination',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Destination grid using Province enum
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  final province = provinces[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailHomePages(
                            province: province.displayName,
                          ),
                        ),
                      );
                    },
                    child: ProvincesCard(
                      image: province.imagePath,
                      title: province.displayName,
                    ),
                  );
                },
              ),

              // Weekend Trips section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Weekend Trips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Weekend trips grid using Province enum
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: provinces.length,
                itemBuilder: (context, index) {
                  final province = provinces[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailHomePages(
                            province: province.displayName,
                          ),
                        ),
                      );
                    },
                    child: ProvincesCard(
                      image: province.imagePath,
                      title: province.displayName,
                    ),
                  );
                },
              ),

              const SizedBox(height: 80), // Bottom padding for navigation bar
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Shadow color
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(2, 4), // Changes position of shadow
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            print("Chatbot button clicked");
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ChatScreen()));
            // Add navigation or functionality here
          },
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 0, // Set to 0 to use the custom shadow
          child: Image.asset(
            'assets/images/chatbot.jpg', // Replace with the actual asset path
            width: 40, // Adjust size as needed
            height: 40,
          ),
        ),
      ),
      bottomNavigationBar: const Navigationbar(),
    );
  }
}

class ProvincesCard extends StatelessWidget {
  final String image;
  final String title;

  const ProvincesCard({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
