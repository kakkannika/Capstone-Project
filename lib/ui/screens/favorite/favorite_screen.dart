// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:iconsax/iconsax.dart';
import 'package:tourism_app/models/place/place.dart';
import 'package:tourism_app/theme/theme.dart';
import 'package:tourism_app/ui/providers/favorite_provider.dart';
import 'package:tourism_app/ui/screens/home/detail_each_place.dart';
import 'package:tourism_app/ui/widgets/navigationBar.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure favorites are loaded on screen initialization
    // No need to call explicitly as the provider loads favorites on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Favorites',
          style: TextStyle(
              color: DertamColors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: DertamColors.white,
        foregroundColor: DertamColors.black,
        centerTitle: true,
      ),
      body: Container(
        color: DertamColors.white,
        child: Consumer<FavoriteProvider>(
          builder: (context, favoriteProvider, child) {
            if (favoriteProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (favoriteProvider.favoritePlaces.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No favorites yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start exploring and add places to your favorites',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProvider.favoritePlaces.length,
              itemBuilder: (context, index) {
                final place = favoriteProvider.favoritePlaces[index];
                return _FavoriteItem(
                  place: place,
                  onRemove: () {
                    // Remove locally first for immediate UI feedback
                    setState(() {});
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const Navigationbar(currentIndex: 2),
    );
  }
}

class _FavoriteItem extends StatefulWidget {
  final Place place;
  final VoidCallback onRemove;

  const _FavoriteItem({
    required this.place,
    required this.onRemove,
  });

  @override
  _FavoriteItemState createState() => _FavoriteItemState();
}

class _FavoriteItemState extends State<_FavoriteItem> {
  bool _removed = false;

  @override
  Widget build(BuildContext context) {
    if (_removed) {
      return const SizedBox.shrink(); // Hide immediately when removed
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailEachPlace(placeId: widget.place.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    widget.place.imageURL,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Iconsax.heart5,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () {
                        // Get provider without listening to changes
                        final provider = Provider.of<FavoriteProvider>(context,
                            listen: false);

                        // Update local state immediately
                        setState(() {
                          _removed = true;
                        });

                        // Notify parent to refresh if needed
                        widget.onRemove();

                        // Update provider in the background
                        provider.toggleFavorite(widget.place.id);
                      },
                      constraints: const BoxConstraints(
                        minHeight: 36,
                        minWidth: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            // Details section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.place.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.place.averageRating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.place.category.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.place.description.length > 120
                        ? '${widget.place.description.substring(0, 120)}...'
                        : widget.place.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
