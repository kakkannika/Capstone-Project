import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/place_model.dart';
import 'package:tourism_app/providers/trip_provider.dart';
import 'package:tourism_app/services/place_service.dart';

class SearchPlaceScreen extends StatefulWidget {
  final String tripId;
  final String dayId;
  final Function(Place) onPlaceSelected;

  const SearchPlaceScreen({
    Key? key,
    required this.tripId,
    required this.dayId,
    required this.onPlaceSelected,
  }) : super(key: key);

  @override
  _SearchPlaceScreenState createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PlaceService _placeService = PlaceService();
  List<Place> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _placeService.searchPlaces(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error searching places: $e';
        _isLoading = false;
      });
    }
  }

  void _addPlaceToDay(Place place) async {
    final tripProvider = context.read<TripViewModel>();
    
    try {
      // Show loading indicator
      setState(() {
        _isLoading = true;
      });
      
      // Add the place to the day
      await tripProvider.addPlaceToDay(
        dayId: widget.dayId,
        placeId: place.id,
      );
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${place.name} added to your itinerary'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        
        // Call the callback to update the UI
        widget.onPlaceSelected(place);
        
        // Return to the previous screen
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding place: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Reset loading state
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add a Place',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a place...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF0D3E4C)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0D3E4C)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  onChanged: (value) {
                    _searchPlaces(value);
                  },
                ),
              ),
              
              // Divider
              Container(
                height: 1,
                color: Colors.grey[300],
              ),
              
              // Search Results
              Expanded(
                child: _isLoading && _searchResults.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                        : _searchResults.isEmpty
                            ? Center(
                                child: _searchController.text.isEmpty
                                    ? const Text('Search for places to add to your itinerary')
                                    : const Text('No places found. Try a different search term.'),
                              )
                            : ListView.builder(
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final place = _searchResults[index];
                                  return _buildPlaceListItem(place);
                                },
                              ),
              ),
            ],
          ),
          
          // Loading Overlay when adding a place
          if (_isLoading && _searchResults.isNotEmpty)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceListItem(Place place) {
    return InkWell(
      onTap: () => _addPlaceToDay(place),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          children: [
            // Place Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: place.imageUrls.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(place.imageUrls.first),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: place.imageUrls.isEmpty ? Colors.grey[300] : null,
              ),
              child: place.imageUrls.isEmpty
                  ? const Icon(Icons.image, color: Colors.grey)
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Place Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Add Button
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF0D3E4C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 