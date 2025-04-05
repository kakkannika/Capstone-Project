// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/place/place.dart';

import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/ui/providers/place_provider.dart';
import 'package:tourism_app/ui/providers/trip_provider.dart';

/// This screen allows users to search for places to add to their trip itinerary.
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
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaceProvider>(
      builder: (context, placeProvider, child) {
        return Scaffold(
          backgroundColor: DertamColors.white,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12), // Reduced spacing

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),

                      // Search TextField
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: DertamColors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Search for places...',
                              hintStyle: TextStyle(
                                color: DertamColors.grey,
                                fontSize: 15,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: DertamColors.grey,
                                size: 22,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: DertamColors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        placeProvider.searchPlace('');
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {}); // Refresh the clear button
                              placeProvider.searchPlace(value);
                            },
                            textInputAction: TextInputAction.search,
                            style: TextStyle(
                              color: DertamColors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Results Header
                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          "Results for \"${_searchController.text}\"",
                          style: TextStyle(
                            color: DertamColors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (placeProvider.places.isNotEmpty)
                          Text(
                            "${placeProvider.places.length} places found",
                            style: TextStyle(
                              color: DertamColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Search Results
                Expanded(
                  child: _isLoading && placeProvider.places.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Text(_error!,
                                  style: const TextStyle(color: Colors.red)))
                          : placeProvider.places.isEmpty
                              ? _buildNoResultsFound()
                              : ListView.builder(
                                  itemCount: placeProvider.places.length,
                                  itemBuilder: (context, index) {
                                    final place = placeProvider.places[index];
                                    return _buildPlaceListItem(place);
                                  },
                                ),
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
          ),
        );
      },
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/panda.png',
            width: 160,
            height: 160,
          ),
          const SizedBox(height: 12),
          Text(
            "No search found",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: DertamColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Sorry, no results match your search criteria.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: DertamColors.grey,
              ),
            ),
          ),
        ],
      ),
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
                          color: DertamColors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
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