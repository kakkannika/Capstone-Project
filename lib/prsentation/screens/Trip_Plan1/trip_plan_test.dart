import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app/prsentation/screens/Trip_Plan1/search_screen.dart';
import 'package:tourism_app/prsentation/screens/Trip_Plan1/start_planning.dart';
import '../Trip_Plan1/plan_trip_detail.dart';

class TripPlannerScreen extends StatefulWidget {
  final List<String?> selectedDestinations;
  final DateTime startDate;
  final DateTime? returnDate;
  
  const TripPlannerScreen({
    Key? key,
    required this.selectedDestinations,
    required this.startDate,
    this.returnDate,
  }) : super(key: key);
  
  @override
  _TripPlannerScreenState createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Overview', 'Itinerary', '\$'];
  bool isNotesExpanded = true;
  bool isPlacesExpanded = true;
  bool isNewTitleExpanded = true;
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.startDate;
  }
  
  @override
  Widget build(BuildContext context) {
    // Get first non-null destination or use 'Unknown' as fallback
    String primaryDestination = 'Unknown';
    for (String? destination in widget.selectedDestinations) {
      if (destination != null && destination.isNotEmpty) {
        primaryDestination = destination;
        break;
      }
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildStatusBar(),
                _buildAppBar('Trip to $primaryDestination'),
                Expanded(
                  child: _selectedTabIndex == 0 
                      ? _buildOverviewTab(primaryDestination)
                      : Container(), // This will be empty as we navigate to a different screen for Itinerary
                ),
              ],
            ),
            _buildFloatingButtons(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewTab(String primaryDestination) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeroImage(),
          _buildTripInfoCard(primaryDestination),
          _buildTabs(),
          _buildSectionCard(_buildNotesSection()),
          _buildSectionCard(_buildRecommendedPlacesSection()),
          _buildSectionCard(_buildNewTitleSection()),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
  
  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.white,
    );
  }
  
  Widget _buildAppBar(String title) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
  
  Widget _buildHeroImage() {
    return Container(
      height: 180,
      width: double.infinity,
      child: Image.network(
        'https://lp-cms-production.imgix.net/2025-01/Cambodia-Angkor-Wat-Waj-shutterstockRF312461543-crop.jpg?auto=format&q=72&w=1440&h=810&fit=crop',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTripInfoCard(String primaryDestination) {
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip to $primaryDestination',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Text(
                  _selectedDate == null
                      ? 'Select trip date'
                      : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Destinations: ${widget.selectedDestinations.where((d) => d != null && d.isNotEmpty).join(', ')}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (widget.returnDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                'Return: ${DateFormat('MMM dd, yyyy').format(widget.returnDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Duration: ${_calculateDuration()} days',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _calculateDuration() {
    if (widget.returnDate == null) {
      return '2'; // Default to 2 days if no return date
    }
    
    return widget.returnDate!.difference(widget.startDate).inDays.toString();
  }
  
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = i;
                  });
                  
                  // Navigate based on tab selection
                  if (i == 0) {
                    // Stay on current screen (Overview)
                    setState(() {
                      _selectedTabIndex = 0;
                    });
                  } else if (i == 1) {
                    // Navigate to Itinerary page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItineraryPage(),
                      ),
                    ).then((_) {
                      // When returning from Itinerary, reset the selected tab to Overview
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTabIndex == i
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        color: _selectedTabIndex == i
                            ? Colors.blue
                            : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSectionCard(Widget content) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: content,
    );
  }
  
  Widget _buildSectionHeader(String title, bool isExpanded, Function() onToggle) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
              color: Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.more_horiz,
              color: Colors.black54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Notes', isNotesExpanded, () {
          setState(() {
            isNotesExpanded = !isNotesExpanded;
          });
        }),
        if (isNotesExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write or paste general notes here, e.g. how to get there, things to bring, etc.',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPlaceCard(String imageUrl, String name) {
    return Stack(
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddPlaceCard(String name, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 20, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecommendedPlacesSection() {
    // Temple image URLs
    final String templeUrl = 'https://lp-cms-production.imgix.net/2025-01/Cambodia-Angkor-Wat-Waj-shutterstockRF312461543-crop.jpg?auto=format&q=72&w=1440&h=810&fit=crop';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Recommended Places', isPlacesExpanded, () {
          setState(() {
            isPlacesExpanded = !isPlacesExpanded;
          });
        }),
        if (isPlacesExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Grid of temple images
                Row(
                  children: [
                    Expanded(child: _buildPlaceCard(templeUrl, 'Angkor Wat')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPlaceCard(templeUrl, 'Bayon Temple')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildPlaceCard(templeUrl, 'Ta Prohm')),
                  ],
                ),
                const SizedBox(height: 12),
                // Add place cards
                Row(
                  children: [
                    Expanded(
                      child: _buildAddPlaceCard('Royal Palace', templeUrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAddPlaceCard('Koh Rong Island', templeUrl),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    // Navigate to attractions search
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailedSearchScreen(),
                      ),
                    ).then((selectedAttraction) {
                      if (selectedAttraction != null) {
                        // Handle the selected attraction
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added $selectedAttraction to your trip')),
                        );
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    child: const Center(
                      child: Text(
                        'BROWSE MORE ATTRACTIONS',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildNewTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Trip Activities', isNewTitleExpanded, () {
          setState(() {
            isNewTitleExpanded = !isNewTitleExpanded;
          });
        }),
        if (isNewTitleExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.directions_walk, color: Colors.blue),
                  title: const Text('Visit Temples'),
                  subtitle: const Text('Explore ancient Khmer temples'),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () {
                    // Add activity to itinerary
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.orange),
                  title: const Text('Cambodian Cuisine'),
                  subtitle: const Text('Try local dishes and delicacies'),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () {
                    // Add activity to itinerary
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions_boat, color: Colors.green),
                  title: const Text('Tonle Sap Lake Tour'),
                  subtitle: const Text('Visit floating villages'),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () {
                    // Add activity to itinerary
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Open map view
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 28,
                child: Icon(Icons.map, color: Colors.white, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              // Show add options dialog
              _showAddOptionsDialog(context);
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                backgroundColor: Color(0xFF2196F3),
                radius: 28,
                child: Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showAddOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.place, color: Colors.red),
                title: const Text('Add Attraction'),
                onTap: () {
                  // Navigator.pop(context);
                  // // Navigate to attraction search
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => (),
                  //   ),
                  // );
                },
              ),
              ListTile(
                leading: const Icon(Icons.hotel, color: Colors.blue),
                title: const Text('Add Accommodation'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to accommodation search
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.orange),
                title: const Text('Add Restaurant'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to restaurant search
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.green),
                title: const Text('Add Transportation'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to transportation options
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}