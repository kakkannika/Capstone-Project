import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourism_app/data/models/Trip_Plan/trip_model.dart';
import 'package:tourism_app/prsentation/screens/Trip_Plan1/ItineraryPage/ItineraryPage.dart';
class TripPlannerScreen extends StatefulWidget {
  final List<String?> selectedDestinations;
  final DateTime startDate;
  DateTime? returnDate;
  
   TripPlannerScreen({
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
  bool isActivitiesExpanded = true;
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
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  
                  centerTitle: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildHeroImage(),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                _buildTripInfoCard(primaryDestination),
                _buildTabs(
                  
                ),
                Expanded(
                  child: _selectedTabIndex == 0
                      ? _buildOverviewContent()
                      : Container(),
                ),
              ],
            ),
          ),
          _buildFloatingButtons(),
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

                // Navigation logic here
                if (i == 1) {
                  // Navigate to Itinerary page with trip data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItineraryPage(
                        trip: TripModel(
                          selectedDestinations: widget.selectedDestinations,
                          startDate: widget.startDate,
                          returnDate: widget.returnDate,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTabIndex == i
                          ? Colors.blue
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTabIndex == i ? Colors.blue : Colors.grey,
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
  
  Widget _buildOverviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          _buildSectionCard(_buildNotesSection()),
          _buildSectionCard(_buildRecommendedPlacesSection()),
          _buildSectionCard(_buildActivitiesSection()),
        ],
      ),
    );
  }
  
  Widget _buildHeroImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://lp-cms-production.imgix.net/2025-01/Cambodia-Angkor-Wat-Waj-shutterstockRF312461543-crop.jpg?auto=format&q=72&w=1440&h=810&fit=crop',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 80, color: Colors.grey),
            );
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Text(
            'Trip to ${widget.selectedDestinations.first ?? "Unknown"}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTripInfoCard(String primaryDestination) {
  return Card(
    margin: const EdgeInsets.all(12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.blue),
              SizedBox(width: 12),
              GestureDetector(
                onTap: _selectDate,
                child: Text(
                  _selectedDate == null
                      ? 'Select trip dates'
                      : '${DateFormat('MMM dd, yyyy').format(_selectedDate!)} - ${widget.returnDate == null ? 'Select return date' : DateFormat('MMM dd, yyyy').format(widget.returnDate!)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24),
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Destinations: ${widget.selectedDestinations.where((d) => d != null && d.isNotEmpty).join(', ')}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          if (widget.returnDate != null) Divider(height: 24),
          if (widget.returnDate != null)
            Row(
              children: [
                Icon(Icons.flight_land, size: 18, color: Colors.green),
                SizedBox(width: 12),
                Text(
                  'Return: ${DateFormat('MMM dd, yyyy').format(widget.returnDate!)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          Divider(height: 24),
          Row(
            children: [
              Icon(Icons.timeline, size: 18, color: Colors.orange),
              SizedBox(width: 12),
              Text(
                'Duration: ${_calculateDuration()} days',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
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
  DateTimeRange? picked = await showDateRangePicker(
    context: context,
    initialDateRange: DateTimeRange(
      start: _selectedDate ?? DateTime.now(),
      end: widget.returnDate ?? (_selectedDate ?? DateTime.now()).add(Duration(days: 2)),
    ),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      _selectedDate = picked.start;
      widget.returnDate = picked.end;
    });
  }
}
  
  
  Widget _buildSectionCard(Widget content) {
    return Card(
      margin: EdgeInsets.only(left: 12, right: 12, top: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: content,
    );
  }
  
  Widget _buildSectionHeader(String title, bool isExpanded, Function() onToggle) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: Duration(milliseconds: 200),
              child: Icon(
                Icons.arrow_right,
                color: Colors.black87,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
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
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write or paste general notes here, e.g. how to get there, things to bring, etc.',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                fillColor: Colors.grey[50],
                filled: true,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildPlaceCard(String imageUrl, String name) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 30, color: Colors.grey),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2.0,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAddPlaceCard(String name, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Action for adding place
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 24, color: Colors.grey),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 20, color: Colors.blue),
                ),
              ],
            ),
          ),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const  EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Grid of temple images with more spacing and improved layout
                Row(
                  children: [
                    Expanded(child: _buildPlaceCard(templeUrl, 'Angkor Wat')),
                   const  SizedBox(width: 10),
                    Expanded(child: _buildPlaceCard(templeUrl, 'Bayon Temple')),
                    const SizedBox(width: 10),
                    Expanded(child: _buildPlaceCard(templeUrl, 'Ta Prohm')),
                  ],
                ),
               const  SizedBox(height: 16),
                // Add place cards
                Row(
                  children: [
                    Expanded(
                      child: _buildAddPlaceCard('Royal Palace', templeUrl),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildAddPlaceCard('Koh Rong Island', templeUrl),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to attractions search
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      Icon(Icons.search, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'BROWSE MORE ATTRACTIONS',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildActivityItem(IconData icon, Color iconColor, String title, String subtitle) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Add activity to itinerary
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
               const  SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                     const  SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline, color: Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Trip Activities', isActivitiesExpanded, () {
          setState(() {
            isActivitiesExpanded = !isActivitiesExpanded;
          });
        }),
        if (isActivitiesExpanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildActivityItem(
                  Icons.temple_buddhist,
                  Colors.blue,
                  'Visit Temples',
                  'Explore ancient Khmer temples',
                ),
                _buildActivityItem(
                  Icons.restaurant,
                  Colors.orange,
                  'Cambodian Cuisine',
                  'Try local dishes and delicacies',
                ),
                _buildActivityItem(
                  Icons.directions_boat,
                  Colors.green,
                  'Tonle Sap Lake Tour',
                  'Visit floating villages',
                ),
                SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    // Add custom activity
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'ADD CUSTOM ACTIVITY',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'map',
            backgroundColor: Colors.white,
            onPressed: () {
              // Open map view
            },
            child: Icon(Icons.map, color: Colors.blue),
            elevation: 4,
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
            backgroundColor: Colors.blue,
            onPressed: () {
              // Show add options dialog
              _showAddOptionsDialog(context);
            },
            child: Icon(Icons.add, color: Colors.white),
            elevation: 4,
          ),
        ],
      ),
    );
  }
  
  void _showAddOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add to Trip',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildAddOptionButton(
                  context,
                  Icons.place,
                  Colors.red,
                  'Add Attraction',
                  () {
                    Navigator.pop(context);
                    // Navigate to attraction search
                  },
                ),
                _buildAddOptionButton(
                  context,
                  Icons.hotel,
                  Colors.blue,
                  'Add Accommodation',
                  () {
                    Navigator.pop(context);
                    // Navigate to accommodation search
                  },
                ),
                _buildAddOptionButton(
                  context,
                  Icons.restaurant,
                  Colors.orange,
                  'Add Restaurant',
                  () {
                    Navigator.pop(context);
                    // Navigate to restaurant search
                  },
                ),
                _buildAddOptionButton(
                  context,
                  Icons.directions_car,
                  Colors.green,
                  'Add Transportation',
                  () {
                    Navigator.pop(context);
                    // Navigate to transportation options
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  
  Widget _buildAddOptionButton(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




