import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/models/trip_model/trip.dart';
import 'package:tourism_app/models/trip_model/day.dart';
import 'package:tourism_app/models/place_model.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app/views/trips_screen/search_place_screen.dart';

class ItineraryPage extends StatefulWidget {
  final String? tripId;
  
  const ItineraryPage({
    Key? key, 
    this.tripId,
  }) : super(key: key);

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _selectedIndex = 1; // Set initial index to 1 for Itinerary
  int _selectedDayIndex = 0; // Track the selected day tab

  @override
  void initState() {
    super.initState();
    // If tripId is provided, load the trip data
    if (widget.tripId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TripViewModel>().selectTrip(widget.tripId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripViewModel>(
      builder: (context, tripProvider, child) {
        final trip = tripProvider.selectedTrip;
        final isLoading = tripProvider.isLoading;
        final error = tripProvider.error;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (error != null) {
          return Center(child: Text('Error: $error'));
        }

        if (trip == null) {
          return const Center(child: Text('No trip selected'));
        }

        return WillPopScope(
          onWillPop: () async => false, // Disable back button
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false, // Remove auto back button
              title: Text(
                trip.tripName,
                style: const TextStyle(color: Colors.black, fontSize: 18),
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
                      _buildItineraryPage(trip),
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
                  backgroundColor: const Color(0xFF0D3E4C),
                  heroTag: 'map',
                  child: const Icon(Icons.map, color: Colors.white),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: () {
                    if (trip.days.isNotEmpty && _selectedDayIndex < trip.days.length) {
                      _navigateToSearchPlace(trip.days[_selectedDayIndex]);
                    }
                  },
                  backgroundColor: const Color(0xFF0D3E4C),
                  heroTag: 'add',
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _navigateToSearchPlace(Day day) {
    final tripProvider = context.read<TripViewModel>();
    if (tripProvider.selectedTrip == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPlaceScreen(
          tripId: tripProvider.selectedTrip!.id,
          dayId: day.id,
          onPlaceSelected: (Place place) {
            // Add the selected place to the day
            tripProvider.addPlaceToDay(
              dayId: day.id,
              placeId: place.id,
            );
          },
        ),
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
                color: isSelected ? const Color(0xFF0D3E4C) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0D3E4C) : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItineraryPage(Trip trip) {
    if (trip.days.isEmpty) {
      return const Center(child: Text('No days in this trip'));
    }

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
                color: Color(0xFF0D3E4C),
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
                    ...List.generate(trip.days.length, (index) {
                      final day = trip.days[index];
                      final date = trip.startDate.add(Duration(days: index));
                      final dateStr = DateFormat('EEE d/M').format(date);
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                          child: _buildDatePill(dateStr, index == _selectedDayIndex),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Selected Day Content
        if (_selectedDayIndex < trip.days.length) _buildDayContent(trip.days[_selectedDayIndex]),
      ],
    );
  }

  Widget _buildDayContent(Day day) {
    final date = context.read<TripViewModel>().selectedTrip!.startDate.add(Duration(days: day.dayNumber - 1));
    final dateStr = DateFormat('EEE d/M').format(date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Row(
          children: [
            Text(
              dateStr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3E4C),
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
        
        const SizedBox(height: 16),
        
        // Places for this day
        if (day.places.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('No places added to this day yet')),
          )
        else
          ...day.places.map((place) => Column(
            children: [
              _buildPlaceCard(place),
              const SizedBox(height: 16),
            ],
          )).toList(),
        
        // Add a place button
        _buildAddPlaceButton(day),
        
        const SizedBox(height: 24),
        
        // Recommended Places
        _buildRecommendedPlacesSection(),
      ],
    );
  }

  Widget _buildDatePill(String date, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0D3E4C).withOpacity(0.2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        date,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0D3E4C) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
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
                    const Icon(Icons.location_on, color: Color(0xFF0D3E4C), size: 20),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  place.description,
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
          if (place.imageUrls.isNotEmpty)
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(place.imageUrls.first),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) => const AssetImage('assets/images/placeholder.jpg'),
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildAddPlaceButton(Day day) {
    return GestureDetector(
      onTap: () => _navigateToSearchPlace(day),
      child: Container(
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
              child: const Icon(Icons.add, color: Colors.grey, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedPlacesSection() {
    return Column(
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
            _buildRecommendedPlace('Angkor Wat', 'assets/images/angkor_wat.jpg'),
          ],
        ),
      ],
    );
  }

  Widget _buildRecommendedPlace(String name, String imageUrl) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // In a real app, this would navigate to place details or add it directly
        },
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
      ),
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}