import 'package:flutter/material.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({Key? key}) : super(key: key);

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1; // Set initial index to 1 for Itinerary

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          onPressed: () {
            // Navigate to home
          },
        ),
        title: const Text(
          'Trip to Siem Reap',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTabButton('Overview', 0),
                _buildTabButton('Itinerary', 1),
                _buildTabButton('\$', 2),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          
          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                const Center(child: Text('Overview Page')),
                _buildItineraryPage(),
                const Center(child: Text('Budget Page')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.blue,
            heroTag: 'map',
            child: const Icon(Icons.map, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.blue,
            heroTag: 'add',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItineraryPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Calendar Icon
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
            ),
            
            // Date Pills
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    _buildDatePill('Wed 1/8', true),
                    const SizedBox(width: 10),
                    _buildDatePill('Thu 1/9', false),
                    const SizedBox(width: 10),
                    _buildDatePill('Fri 1/10', false),
                    const SizedBox(width: 10),
                    _buildDatePill('Sat 1/11', false),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Day 1 Itinerary
        _buildItineraryDay(
          date: 'Wed 1/8',
          place: 'Angkor Wat',
          description: 'From the web: This iconic, sprawling temple complex is surrounded by a wide moat & fea...',
          imageUrl: 'assets/images/angkor_wat.jpg'
        ),
        
        const SizedBox(height: 16),
        
        // Add a place button for day 1
        _buildAddPlaceButton(),
        
        const SizedBox(height: 24),
        
        // Day 2 Itinerary
        _buildItineraryDay(
          date: 'Thu 1/9',
          place: 'Angkor Wat',
          description: 'From the web: This iconic, sprawling temple complex is surrounded by a wide moat & fea...',
          imageUrl: 'assets/images/angkor_wat.jpg'
        ),
        
        const SizedBox(height: 16),
        
        // Add a place button for day 2
        _buildAddPlaceButton(),
        
        const SizedBox(height: 24),
        
        // Recommended Places
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommended places',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRecommendedPlace('Royal Palaces', 'assets/images/royal_palace.jpg'),
                const SizedBox(width: 16),
                _buildRecommendedPlace('Royal Palaces', 'assets/images/royal_palace.jpg'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePill(String date, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        date,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildItineraryDay({
    required String date,
    required String place,
    required String description,
    required String imageUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date
        Row(
          children: [
            Text(
              date,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Add subheading',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Place card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          place,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Image
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddPlaceButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            'Add a place',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const Spacer(),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.copy, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedPlace(String name, String imageUrl) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    image: DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Title
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // Add button
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

