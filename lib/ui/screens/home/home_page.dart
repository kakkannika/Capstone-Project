import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tourism_app/ui/providers/place_provider.dart';
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
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get all provinces as a list
    final List<Province> provinces = Province.values;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile and icons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Hello, Kannika',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Hero image and search bar
              Stack(
                children: [
                  Image.asset(
                    'assets/place_images/Angkor.jpg',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                     
                    ),
                  ),
                ],
              ),

              // Popular destination section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular destination',
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
                              builder: (context) =>
                                  ProvincePlacesScreen(province: province),
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
                          builder: (context) =>
                              ProvincePlacesScreen(province: province),
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
                          builder: (context) =>
                              ProvincePlacesScreen(province: province),
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

class ProvincePlacesScreen extends StatelessWidget {
  final Province province;

  const ProvincePlacesScreen({super.key, required this.province});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          PlaceProvider()..fetchPlacesByProvince(province.displayName),
      child: Scaffold(
        appBar: AppBar(
          title: Text(province.displayName),
        ),
        body: Consumer<PlaceProvider>(
          builder: (context, placeProvider, child) {
            if (placeProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: placeProvider.places.length,
              itemBuilder: (context, index) {
                final place = placeProvider.places[index];
                return ListTile(
                  leading: Image.network(place.imageURL,
                      width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(place.name),
                  subtitle: Text(place.description),
                );
              },
            );
          },
        ),
      ),
    );
  }
}