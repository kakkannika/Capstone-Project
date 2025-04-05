import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/ui/theme/theme.dart';
import 'package:tourism_app/ui/providers/place_provider.dart';
import 'package:tourism_app/ui/screens/home/detail_each_place.dart';

class PlacePicker extends StatefulWidget {
  final Place? initPlace;
  final String province;

  const PlacePicker({super.key, this.initPlace, required this.province});

  @override
  State<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  List<Place> filteredPlaces = [];
  bool hasSearched = false; // Track if user has searched

  void onBackSelected() {
    Navigator.of(context).pop();
  }

  void onPlaceSelected(Place place) {
    // Navigate to the detail page instead of popping
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailEachPlace(placeId: place.id),
      ),
    );
  }

  void onSearchChanged(String searchText) {
    if (searchText.length > 1) {
      final provider = Provider.of<PlaceProvider>(context, listen: false);
      provider.searchPlace(searchText).then((_) {
        setState(() {
          filteredPlaces = provider.places
              .where((place) => place.province == widget.province)
              .toList();
          hasSearched = true; // Set the flag when search is performed
        });
      });
    } else if (searchText.isEmpty) {
      setState(() {
        filteredPlaces = [];
        hasSearched = false; // Reset flag when search text is cleared
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DertamColors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBar(
              onBackPressed: onBackSelected,
              onSearchChanged: onSearchChanged,
            ),
            Expanded(
              child: Consumer<PlaceProvider>(
                builder: (context, provider, child) {
                  if (provider.error != null) {
                    return Center(child: Text(provider.error!));
                  }

                  if (!hasSearched) {
                    // Empty state when no search has been performed
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Search for places...",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // No results state
                  if (filteredPlaces.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No places found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show results
                  return ListView.builder(
                    itemCount: filteredPlaces.length,
                    itemBuilder: (ctx, index) => PlaceTile(
                      place: filteredPlaces[index],
                      onSelected: onPlaceSelected,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceTile extends StatelessWidget {
  final Place place;
  final Function(Place place) onSelected;

  const PlaceTile({super.key, required this.place, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onSelected(place),
      leading: place.imageURL.isNotEmpty
          ? Image.network(
              place.imageURL,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            )
          : Container(
              width: 50,
              height: 50,
              color: Colors.grey[200],
              child: Icon(Icons.place, color: Colors.grey),
            ),
      title: Text(place.name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(place.province),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

class SearchBar extends StatefulWidget {
  final Function(String text) onSearchChanged;
  final VoidCallback onBackPressed;

  const SearchBar(
      {super.key, required this.onSearchChanged, required this.onBackPressed});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get searchIsNotEmpty => _controller.text.isNotEmpty;

  void onChanged(String newText) {
    widget.onSearchChanged(newText);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBackPressed,
            icon: Icon(Icons.arrow_back_ios, size: 16),
          ),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              onChanged: onChanged,
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search places...",
                border: InputBorder.none,
              ),
            ),
          ),
          searchIsNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    _focusNode.requestFocus();
                    onChanged("");
                  },
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
