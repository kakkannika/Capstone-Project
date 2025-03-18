// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/providers/place_provider.dart';
import 'package:tourism_app/providers/trip_provider.dart';

class SearchPlaceScreen extends StatefulWidget {
  final String tripId;
  final String dayId;
  final Function(Place) onPlaceSelected;

  const SearchPlaceScreen({
    super.key,
    required this.tripId,
    required this.dayId,
    required this.onPlaceSelected,
  });

  @override
  _SearchPlaceScreenState createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaceProvider>(
      builder: (context, placeProvider, child) {
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
                        prefixIcon:
                            const Icon(Icons.search, color: Color(0xFF0D3E4C)),
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
                          borderSide:
                              const BorderSide(color: Color(0xFF0D3E4C)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                      onChanged: (value) {
                        placeProvider.searchPlace(value);
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
                    child: _isLoading && placeProvider.places.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(
                                child: Text(_error!,
                                    style: const TextStyle(color: Colors.red)))
                            : placeProvider.places.isEmpty
                                ? Center(
                                    child: _searchController.text.isEmpty
                                        ? const Text(
                                            'Search for places to add to your itinerary')
                                        : const Text(
                                            'No places found. Try a different search term.'),
                                  )
                                : ListView.builder(
                                    itemCount: placeProvider.places.length,
                                    itemBuilder: (context, index) {
                                      final place = placeProvider.places[index];
                                      return _buildPlaceListItem(place);
                                    },
                                  ),
                  ),
                ],
              ),

              // Loading Overlay when adding a place
              if (_isLoading && placeProvider.places.isNotEmpty)
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
      },
    );
  }

  Widget _buildPlaceListItem(Place place) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        return InkWell(
          onTap: () => tripProvider.addPlaceToDay(
            dayId: widget.dayId,
            placeId: place.id,
            onSuccess: () => Navigator.pop(context, true),
          ),
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
                    image: place.imageURL.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(place.imageURL),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: place.imageURL.isEmpty ? Colors.grey[300] : null,
                  ),
                  child: place.imageURL.isEmpty
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
      },
    );
  }
}
