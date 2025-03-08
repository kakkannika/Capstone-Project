import 'package:flutter/material.dart';
import 'package:tourism_app/data/models/Trip_Plan/trip_model.dart';
import 'package:tourism_app/prsentation/screens/Trip_Plan1/Start_Plan/start_planning.dart';

class ItineraryPage extends StatefulWidget {
  final TripModel trip;

  const ItineraryPage({Key? key, required this.trip}) : super(key: key);

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1; 
  int _selectedDateIndex = 0;
  
  late List<String> _dates;

  @override
  void initState() {
    super.initState();
    _dates = _generateDates(widget.trip.startDate, widget.trip.tripDuration);
  }

  List<String> _generateDates(DateTime startDate, int duration) {
    return List.generate(duration, (index) {
      DateTime date = startDate.add(Duration(days: index));
      return '${date.weekday} ${date.month}/${date.day}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.black87),
          onPressed: () {
            // Navigate to home
          },
        ),
        title: Text(
          'Trip to ${widget.trip.primaryDestination}',
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
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
          padding: const EdgeInsets.symmetric(vertical: 14),
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
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 15,
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
          children: [
            // Calendar Icon
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
            ),
            
            // Date Pills
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_dates.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 12 : 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDateIndex = index;
                          });
                        },
                        child: _buildDatePill(_dates[index], index == _selectedDateIndex),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Day 1 Card (Wed)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Row(
                  children: [
                    Text(
                      'Wed 1/8',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[400],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add subheading',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Location with details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Place name with icon
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue[400], size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'Angkor Wat',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Description
                          const Text(
                            'From the web: This iconic, sprawling temple complex is surrounded by a wide moat & fea...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Image
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Ankor_Wat_temple.jpg/800px-Ankor_Wat_temple.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Add a place button for day 1
        _buildAddPlaceButton(0),
        
        const SizedBox(height: 24),
        
        // Day 2 Card (Thu)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Row(
                  children: [
                    Text(
                      'Thu 1/9',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add subheading',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Location with details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Place name with icon
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                              const SizedBox(width: 4),
                              const Text(
                                'Angkor Wat',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Description
                          const Text(
                            'From the web: This iconic, sprawling temple complex is surrounded by a wide moat & fea...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Image
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Ankor_Wat_temple.jpg/800px-Ankor_Wat_temple.jpg',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Add a place button for day 2
        _buildAddPlaceButton(0),
        
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
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRecommendedPlace(
                  'Royal Palaces', 
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXBvn2jU3EwTQK4a1Sj0SY5kcnHvbuNprdAA&s'
                ),
                const SizedBox(width: 16),
                _buildRecommendedPlace(
                  'Royal Palaces',
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXBvn2jU3EwTQK4a1Sj0SY5kcnHvbuNprdAA&s'
                ),
              ],
            ),
          ],
        ),
        
        // Extra space for FAB
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDatePill(String date, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        date,
        style: TextStyle(
          color: isSelected ? Colors.blue[600] : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAddPlaceButton(int dayIndex) {
  String date = _dates[dayIndex];
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
          spreadRadius: 0,
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
        const SizedBox(width: 8),
        Text(
          'Add a place for $date',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.content_copy_outlined, color: Colors.grey, size: 16),
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
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
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
                  child: Icon(Icons.add, size: 16, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _checkAndNavigate() {
    if (_dates.length == 5) {
      // Create a TripModel instance with the necessary data
      TripModel trip = TripModel(
        selectedDestinations: _dates,
        startDate: widget.trip.startDate,
        returnDate: widget.trip.returnDate,
      );

      // Navigate to PlanNewTripScreen with the trip data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlanNewTripScreen(),
        ),
      );
    } else {
      // Show a message or handle the case where the trip is not 5 days
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip plan must have 5 days to proceed.')),
      );
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}