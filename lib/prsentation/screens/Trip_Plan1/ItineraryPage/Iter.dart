import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app/data/models/Trip_Plan/trip_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    // Example trip data
    final trip = TripModel(
      startDate: DateTime(2025, 3, 8),
      returnDate: DateTime(2025, 3, 15),
      selectedDestinations: ['Paris', 'London', 'Rome'],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tourism App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ItineraryPage(trip: trip),
    );
  }
}
class ItineraryPage extends StatefulWidget {
  final TripModel trip;

  const ItineraryPage({
    Key? key,
    required this.trip,
  }) : super(key: key);

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  int _selectedTabIndex = 1; 
  final List<String> _tabs = ['Overview', 'Itinerary', 'Explore', '\$'];
  List<DateTime> _tripDates = [];
  int _selectedDateIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _generateTripDates();
  }
  
  void _generateTripDates() {
    _tripDates = [];
    if (widget.trip.returnDate != null) {
      final int dayCount = widget.trip.returnDate!.difference(widget.trip.startDate).inDays + 1;
      for (int i = 0; i < dayCount; i++) {
        _tripDates.add(widget.trip.startDate.add(Duration(days: i)));
      }
    } else {
      // Default to 3 days if no return date
      for (int i = 0; i < 3; i++) {
        _tripDates.add(widget.trip.startDate.add(Duration(days: i)));
      }
    }
  }

  String _getDayName(DateTime date) {
    final dayFormat = DateFormat('EEE');
    return dayFormat.format(date);
  }

  String _getDayNumber(DateTime date) {
    final dateFormat = DateFormat('M/d');
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Get first non-null destination or use 'Unknown' as fallback
    String primaryDestination = 'Unknown';
    for (String? destination in widget.trip.selectedDestinations) {
      if (destination != null && destination.isNotEmpty) {
        primaryDestination = destination;
        break;
      }
    }
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(primaryDestination),
            _buildTabs(),
            _buildDateSelector(),
            Expanded(
              child: _buildItineraryContent(),
            ),
          ],
        ),
      ),
      
    );
  }

  Widget _buildAppBar(String destination) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.home, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Trip to $destination',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black54),
            onPressed: () {
              // Share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black54),
            onPressed: () {
              // More options
            },
          ),
        ],
      ),
    );
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
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = i;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedTabIndex == i
                            ? Colors.red
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTabIndex == i ? Colors.red : Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.grey[100],
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_calendar,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: List.generate(
                      _tripDates.length, 
                      (index) => _buildDateButton(index),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(int index) {
    final date = _tripDates[index];
    final isSelected = index == _selectedDateIndex;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDateIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Text(
              _getDayName(date),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _getDayNumber(date),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryContent() {
    final selectedDate = _tripDates[_selectedDateIndex];
    final dayFormat = DateFormat('EEE M/d');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayFormat.format(selectedDate),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Show subheading edit dialog
                },
                child: Row(
                  children: [
                    Text(
                      'Add subheading',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.more_vert, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_fix_high, color: Colors.blue, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Auto-fill day',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Text(' · ', style: TextStyle(color: Colors.grey)),
              Row(
                children: [
                  const Icon(Icons.route, color: Colors.blue, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Optimize route',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildPlaceItem(),
      ],
    );
  }

  Widget _buildPlaceItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Add a place',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_all, color: Colors.grey),
              onPressed: () {
                // Duplicate functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.list, color: Colors.grey),
              onPressed: () {
                // List view functionality
              },
            ),
          ],
        ),
      ),
    );
  }

 
  
}
